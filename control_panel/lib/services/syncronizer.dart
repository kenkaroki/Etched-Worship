import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:control_pannel/controllers/files.dart'
    show sync_dependacies_path;

class WhisperSlideSyncService {
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _pcmSubscription;
  Timer? _sliceTimer;

  bool _running = false;
  bool _processing = false;

  final String whisperBinaryPath;
  final String modelPath;

  // Language handling: we don't hardcode a language, but re-running
  // whisper's auto-detect on every single ~3s chunk is unreliable — one
  // noisy/musical window can flip the guess and garble that chunk's
  // transcription. Instead we let it auto-detect until it reports a
  // confident result, then lock that language in and stop re-guessing.
  // Pass an explicit language here only if you want to skip detection
  // entirely and pin it yourself.
  final String? language;
  String? _lockedLanguage;
  static const double _languageLockConfidence = 0.6;
  static final RegExp _detectedLanguageRegex = RegExp(
    r'auto-detected language:\s*(\w+)\s*\(p\s*=\s*([\d.]+)\)',
  );

  // Beam search is more accurate than greedy decoding but costs roughly
  // beamSize× the compute per chunk. With a 1s cadence and base model
  // there's usually headroom for a small beam; if transcriptions start
  // lagging (windows getting skipped because _processing is still true),
  // lower this back toward 1 (greedy).
  static const int _beamSize = 3;

  List<String> _slides = [];
  List<List<String>> _normalizedSlides = [];

  // ---- Sliding-window audio capture ----
  // Instead of recording disjoint 3s chunks (0-3, 3-6, 6-9 — each one
  // truncated and context-free), we keep one continuous PCM stream and
  // snapshot the trailing 3 seconds every 1 second (0-3, 1-4, 2-5, 3-6...).
  // Whisper always sees 3s of real context, latency is still ~1s, and
  // words never get chopped off at a hard chunk boundary.
  static const int _sampleRate = 16000;
  static const int _numChannels = 1;
  static const int _bitsPerSample = 16;
  static const Duration _windowDuration = Duration(seconds: 3);
  static const Duration _sliceInterval = Duration(seconds: 1);

  int get _bytesPerSecond => _sampleRate * _numChannels * (_bitsPerSample ~/ 8);
  int get _windowBytes => _bytesPerSecond * _windowDuration.inSeconds;
  // Keep slightly more than one window buffered so a slice is never
  // waiting on data that hasn't arrived yet.
  int get _bufferCapBytes => _windowBytes + _bytesPerSecond;

  Uint8List _pcmBuffer = Uint8List(0);

  // Document-frequency map used for IDF weighting: how many slides
  // contain a given normalized word.
  Map<String, int> _wordDocFrequency = {};
  int _totalSlideCount = 0;

  int currentSlide = -1;

  // Callback passing the highest confidence matched slide index and score
  Function(int slide, double confidence)? onSlideChanged;
  Function(String heardText)? onHeard;

  static const double _minAcceptScore =
      0.35; // Adjusted slightly for short singing snippets

  // Words at or below this length are too short for Levenshtein-based
  // fuzzy matching to be meaningful (almost everything scores >0.7
  // similarity against a 3-4 letter word). Require exact matches instead.
  static const int _minLengthForFuzzyMatch = 5;

  // How many slides before/after the current slide to check first.
  // Presentations are sequential almost all the time, so the right slide
  // is usually right next to where we already are, and restricting the
  // search there first avoids far-away slides "stealing" a match on
  // repeated chorus words.
  static const int _contextWindow = 3;

  // A windowed match needs to clear a slightly higher bar than the
  // global fallback, since we want to be confident before trusting
  // locality over the rest of the deck.
  static const double _contextAcceptScore = 0.45;

  // Filter out common Whisper silence/noise hallucinations
  static const Set<String> _hallucinatedPhrases = {
    'you',
    'you.',
    'thank you',
    'thank you.',
    'subtitles by',
    'mb',
  };

  static const Set<String> _stopwords = {
    'the',
    'a',
    'an',
    'of',
    'and',
    'or',
    'is',
    'it',
    'to',
    'in',
    'on',
    'has',
    'have',
    'who',
    'you',
    'your',
    'i',
    'me',
    'my',
    'we',
    'us',
    'so',
    'as',
    'be',
    'he',
    'she',
    'they',
    'them',
    'that',
    'this',
    'shall',
    'will',
  };

  WhisperSlideSyncService({
    required this.whisperBinaryPath,
    required this.modelPath,
    this.language,
  });

  Future<Directory> get _tmpDir async {
    final dir = Directory('$sync_dependacies_path/tmp');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> start({
    required List<String> slides,
    required Function(int slide, double confidence) onSlideChanged,
    Function(String heardText)? onHeard,
    @Deprecated(
      'Superseded by the fixed _windowDuration/_sliceInterval sliding '
      'window. No longer has any effect; kept so existing call sites '
      'still compile.',
    )
    Duration chunkDuration = const Duration(seconds: 3),
  }) async {
    _slides = slides;
    _normalizedSlides = slides.map(_normalize).toList();
    _buildDocFrequency();

    this.onSlideChanged = onSlideChanged;
    this.onHeard = onHeard;

    final checkRecorder = AudioRecorder();
    if (!await checkRecorder.hasPermission()) {
      await checkRecorder.dispose();
      throw Exception("Microphone permission denied");
    }
    await checkRecorder.dispose();

    if (!await File(whisperBinaryPath).exists()) {
      throw Exception("Speech engine not found at $whisperBinaryPath");
    }
    if (!await File(modelPath).exists()) {
      throw Exception("Speech model not found at $modelPath");
    }

    await _clearStaleChunks();

    _pcmBuffer = Uint8List(0);
    _lockedLanguage = null;
    _running = true;
    await _startStreaming();

    _sliceTimer = Timer.periodic(_sliceInterval, (_) {
      if (!_running) return;
      _processSlice().catchError((e) {
        print("Error processing slice: $e");
      });
    });
  }

  // Builds a document-frequency table across all slides so that words
  // repeated on many slides (e.g. "brutus", "rome", "honor" in a chorus)
  // contribute less to a match than words unique to a single slide
  // (e.g. "summation", "participation", "assassination").
  void _buildDocFrequency() {
    _wordDocFrequency = {};
    _totalSlideCount = _normalizedSlides.length;

    for (final slideWords in _normalizedSlides) {
      final seen = <String>{};
      for (final w in slideWords) {
        seen.add(w);
      }
      for (final w in seen) {
        _wordDocFrequency[w] = (_wordDocFrequency[w] ?? 0) + 1;
      }
    }
  }

  // Inverse-document-frequency style weight. Words on every slide get a
  // weight near a small floor; words unique to one slide get the max weight.
  double _idf(String word) {
    if (_totalSlideCount == 0) return 1.0;
    final df = _wordDocFrequency[word] ?? 1;
    // log(N/df) + 1, floored so no word ever contributes ~0.
    final weight = math.log(_totalSlideCount / df) + 1.0;
    return weight.clamp(0.25, 10.0);
  }

  Future<void> _clearStaleChunks() async {
    try {
      final dir = await _tmpDir;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('chunk_')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> _startStreaming() async {
    _recorder = AudioRecorder();

    final devices = await _recorder!.listInputDevices();
    print(
      "Available input devices: "
      "${devices.map((d) => d.label).join(', ')}",
    );
    InputDevice? targetDevice;
    if (devices.isNotEmpty) {
      targetDevice = devices.firstWhere(
        (d) =>
            d.label.toLowerCase().contains('microphone') ||
            d.label.toLowerCase().contains('realtek') ||
            d.label.toLowerCase().contains('array'),
        orElse: () => devices.first,
      );
      print("Selected input device: ${targetDevice.label}");
    }

    final stream = await _recorder!.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
        // Both of these are tuned for phone-call speech and can distort
        // vocals-over-instrumental audio rather than help it: autoGain
        // pumps up the noise/instrumental floor along with the voice, and
        // noiseSuppress can attenuate parts of the vocal frequency range
        // it mistakes for background noise. Feed whisper the raw signal
        // and let it handle level/noise variance itself.
        autoGain: false,
        noiseSuppress: false,
        device: targetDevice,
      ),
    );

    _pcmSubscription = stream.listen(
      _onPcmData,
      onError: (e) => print("PCM stream error: $e"),
    );
  }

  // Appends new raw PCM bytes to the rolling buffer, trimming from the
  // front once it grows past what a single window snapshot needs.
  void _onPcmData(Uint8List chunk) {
    final combined = Uint8List(_pcmBuffer.length + chunk.length)
      ..setRange(0, _pcmBuffer.length, _pcmBuffer)
      ..setRange(_pcmBuffer.length, _pcmBuffer.length + chunk.length, chunk);

    if (combined.length > _bufferCapBytes) {
      final excess = combined.length - _bufferCapBytes;
      _pcmBuffer = Uint8List.fromList(combined.sublist(excess));
    } else {
      _pcmBuffer = combined;
    }
  }

  // Fires every _sliceInterval (1s). Snapshots the trailing
  // _windowDuration (3s) of buffered audio, wraps it as a standalone WAV
  // file, and transcribes it. Consecutive snapshots overlap heavily by
  // design (that's the whole point of the sliding window).
  Future<void> _processSlice() async {
    if (_processing) return;
    if (_pcmBuffer.isEmpty) return;

    final take = math.min(_windowBytes, _pcmBuffer.length);
    // Not enough audio buffered yet (e.g. first second after start()) —
    // skip this tick rather than transcribing a too-short/silent clip.
    if (take < _bytesPerSecond) return;

    final windowPcm = Uint8List.sublistView(
      _pcmBuffer,
      _pcmBuffer.length - take,
    );

    _processing = true;
    try {
      final dir = await _tmpDir;
      final path =
          '${dir.path}/chunk_${DateTime.now().millisecondsSinceEpoch}.wav';
      final wavBytes = _wrapPcmAsWav(windowPcm);
      await File(path).writeAsBytes(wavBytes, flush: true);
      await _transcribe(path);
    } finally {
      _processing = false;
    }
  }

  // Wraps raw PCM16 mono bytes in a minimal 44-byte WAV header so
  // whisper.cpp (which expects a real WAV file) can read the snapshot.
  Uint8List _wrapPcmAsWav(Uint8List pcm) {
    final byteRate = _bytesPerSecond;
    final blockAlign = _numChannels * (_bitsPerSample ~/ 8);
    final dataLength = pcm.length;

    final header = BytesBuilder();

    void writeString(String s) => header.add(s.codeUnits);
    void writeUint32(int v) => header.add([
      v & 0xff,
      (v >> 8) & 0xff,
      (v >> 16) & 0xff,
      (v >> 24) & 0xff,
    ]);
    void writeUint16(int v) => header.add([v & 0xff, (v >> 8) & 0xff]);

    writeString('RIFF');
    writeUint32(36 + dataLength);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16); // PCM fmt chunk size
    writeUint16(1); // PCM format tag
    writeUint16(_numChannels);
    writeUint32(_sampleRate);
    writeUint32(byteRate);
    writeUint16(blockAlign);
    writeUint16(_bitsPerSample);
    writeString('data');
    writeUint32(dataLength);

    final out = BytesBuilder();
    out.add(header.toBytes());
    out.add(pcm);
    return out.toBytes();
  }

  // Builds an "initial prompt" for whisper from the lyrics around wherever
  // we currently are in the deck. Whisper's --prompt conditions decoding
  // toward this vocabulary/style without forcing it — so when the actual
  // audio is acoustically ambiguous, it leans toward "summation" over
  // "rude" because "summation" is sitting right there in the prompt.
  String _buildContextPrompt() {
    if (_slides.isEmpty) return '';

    final start = currentSlide == -1 ? 0 : math.max(0, currentSlide - 1);
    final end = currentSlide == -1
        ? math.min(_slides.length - 1, 2)
        : math.min(_slides.length - 1, currentSlide + _contextWindow);

    final buffer = StringBuffer();
    for (int i = start; i <= end; i++) {
      buffer.write(_slides[i]);
      buffer.write(' ');
    }

    var text = buffer.toString().trim();

    // Whisper only actually attends to a limited amount of prompt context;
    // keep this short so it's used efficiently and cheap to pass every
    // second. Bias toward the most local (nearest) lyrics if it's long.
    const maxPromptChars = 400;
    if (text.length > maxPromptChars) {
      text = text.substring(text.length - maxPromptChars);
    }

    return text;
  }

  Future<void> _transcribe(String wavPath) async {
    try {
      final outBase = wavPath.replaceAll('.wav', '');
      final prompt = _buildContextPrompt();

      // Explicit language wins if the caller pinned one. Otherwise use
      // whatever we've locked onto so far, or 'auto' until we have.
      final effectiveLanguage = language ?? _lockedLanguage ?? 'auto';

      final args = [
        '-m',
        modelPath,
        '-f',
        wavPath,
        '-nt',
        '-otxt',
        '-of',
        outBase,
        '-mc',
        '0',
        '-et',
        '2.6',
        '-nth',
        '0.6',
        '-l',
        effectiveLanguage,
        '-bs',
        '$_beamSize',
      ];

      if (prompt.isNotEmpty) {
        args.addAll(['--prompt', prompt]);
      }

      final result = await Process.run(whisperBinaryPath, args);

      // Only relevant while we're still on 'auto': lock the language in
      // once whisper reports a confident detection, so we stop
      // re-guessing on every chunk from here on.
      if (language == null && _lockedLanguage == null) {
        final match = _detectedLanguageRegex.firstMatch(
          result.stderr.toString(),
        );
        if (match != null) {
          final detected = match.group(1)!;
          final confidence = double.tryParse(match.group(2)!) ?? 0.0;
          if (confidence >= _languageLockConfidence) {
            _lockedLanguage = detected;
            print(
              "Locked transcription language to '$detected' "
              "(confidence $confidence)",
            );
          }
        }
      }

      if (result.exitCode != 0) {
        print("whisper error: ${result.stderr}");
        await _cleanup(wavPath, outBase);
        return;
      }

      final txtFile = File('$outBase.txt');
      if (!await txtFile.exists()) {
        await _cleanup(wavPath, outBase);
        return;
      }

      final text = (await txtFile.readAsString()).trim();
      await _cleanup(wavPath, outBase);

      if (text.isEmpty) return;

      if (_hallucinatedPhrases.contains(text.toLowerCase())) {
        return;
      }

      print("Heard: $text");
      onHeard?.call(text);

      _handleResult(text);
    } catch (e) {
      print("Transcribe failed: $e");
    }
  }

  Future<void> _cleanup(String wavPath, String outBase) async {
    try {
      final wav = File(wavPath);
      if (await wav.exists()) await wav.delete();
      final txt = File('$outBase.txt');
      if (await txt.exists()) await txt.delete();
    } catch (_) {}
  }

  void _handleResult(String heardText) {
    final match = _findBestSlide(heardText);
    int slide = match.slideIndex;
    double confidence = match.confidence;

    // Direct Instant Activation: If match passes threshold, trigger callback immediately
    if (slide != -1 && confidence >= _minAcceptScore) {
      currentSlide = slide;
      onSlideChanged?.call(slide, confidence);
    }
  }

  void stop() {
    if (!_running) return;

    _running = false;
    _sliceTimer?.cancel();
    _sliceTimer = null;

    _pcmSubscription?.cancel();
    _pcmSubscription = null;

    if (_recorder != null) {
      _recorder!.stop();
      _recorder!.dispose();
      _recorder = null;
    }

    _pcmBuffer = Uint8List(0);
    currentSlide = -1;
  }

  // ================= MATCHING LOGIC =================

  _SlideMatch _findBestSlide(String input) {
    List<String> spokenWords = _normalize(input);
    if (spokenWords.isEmpty) return _SlideMatch(-1, 0.0);

    // 1. Context-aware pass: check the slides around wherever we
    // currently are first. This is where the correct slide almost
    // always is, and it keeps far-away chorus repeats from winning.
    if (currentSlide != -1) {
      final windowStart = math.max(0, currentSlide - _contextWindow);
      final windowEnd = math.min(
        _normalizedSlides.length - 1,
        currentSlide + _contextWindow,
      );

      final windowMatch = _bestInRange(spokenWords, windowStart, windowEnd);

      print(
        "Windowed match [$windowStart-$windowEnd]: "
        "Slide ${windowMatch.slideIndex} with score ${windowMatch.confidence}",
      );

      if (windowMatch.slideIndex != -1 &&
          windowMatch.confidence >= _contextAcceptScore) {
        return windowMatch;
      }
    }

    // 2. Global fallback: nothing nearby was confident enough (or we
    // don't have a current slide yet), so search the whole deck.
    final globalMatch = _bestInRange(
      spokenWords,
      0,
      _normalizedSlides.length - 1,
    );

    print(
      "Global fallback match: Slide ${globalMatch.slideIndex} "
      "with score ${globalMatch.confidence}",
    );

    if (globalMatch.slideIndex == -1 ||
        globalMatch.confidence < _minAcceptScore) {
      return _SlideMatch(-1, globalMatch.confidence);
    }

    return globalMatch;
  }

  // Scans slides in [start, end] (inclusive) and returns the best match.
  _SlideMatch _bestInRange(List<String> spokenWords, int start, int end) {
    double bestScore = 0;
    int bestIndex = -1;

    for (int i = start; i <= end; i++) {
      if (_normalizedSlides[i].isEmpty) continue;
      double score = _slideScore(spokenWords, _normalizedSlides[i]);

      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    return _SlideMatch(bestIndex, bestScore);
  }

  double _slideScore(List<String> spokenWords, List<String> slideWords) {
    double similarity = _wordSimilarity(spokenWords, slideWords);
    double order = _orderScore(spokenWords, slideWords);
    return similarity * 0.7 + order * 0.3;
  }

  List<String> _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((e) => e.isNotEmpty && !_stopwords.contains(e))
        .toList();
  }

  // IDF-weighted word similarity. Distinctive words (unique to one or few
  // slides) drive the score; words that recur across many slides
  // (choruses, repeated names) are heavily discounted so they can't
  // accidentally win a match on their own.
  double _wordSimilarity(List<String> spoken, List<String> slide) {
    double matchedWeight = 0;
    double totalWeight = 0;

    for (String word in spoken) {
      final weight = _idf(word);
      totalWeight += weight;

      double best = 0;
      for (String s in slide) {
        final score = _similarity(word, s);
        if (score > best) best = score;
      }

      if (best >= 1.0) {
        // Exact match always counts fully.
        matchedWeight += weight;
      } else if (word.length >= _minLengthForFuzzyMatch && best >= 0.7) {
        // Fuzzy match only allowed for words long enough that Levenshtein
        // similarity is meaningful.
        matchedWeight += weight * best;
      }
    }

    if (totalWeight == 0) return 0;
    return matchedWeight / totalWeight;
  }

  double _orderScore(List<String> spoken, List<String> slide) {
    List<int> positions = [];

    for (String word in spoken) {
      int index = -1;
      double best = 0;

      for (int i = 0; i < slide.length; i++) {
        double score = _similarity(word, slide[i]);
        final threshold = word.length >= _minLengthForFuzzyMatch ? 0.7 : 1.0;
        if (score > best && score >= threshold) {
          best = score;
          index = i;
        }
      }

      if (index != -1) positions.add(index);
    }

    if (positions.length < 2) return 1;

    int correct = 0;
    for (int i = 0; i < positions.length - 1; i++) {
      if (positions[i] < positions[i + 1]) correct++;
    }

    return correct / (positions.length - 1);
  }

  double _similarity(String a, String b) {
    if (a == b) return 1.0;
    int distance = _levenshtein(a, b);
    int length = a.length > b.length ? a.length : b.length;
    if (length == 0) return 1;
    return 1 - distance / length;
  }

  int _levenshtein(String a, String b) {
    List<List<int>> dp = List.generate(
      a.length + 1,
      (_) => List.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) dp[i][0] = i;
    for (int j = 0; j <= b.length; j++) dp[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[a.length][b.length];
  }
}

class _SlideMatch {
  final int slideIndex;
  final double confidence;
  _SlideMatch(this.slideIndex, this.confidence);
}
