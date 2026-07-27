import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:control_pannel/controllers/files.dart'
    show sync_dependacies_path;

class AudioSyncSettingsService {
  static const _prefsKey = 'audio_sync_enabled';
  static const _whisperVersion =
      'v1.9.1'; // pin so upstream can't rename under us

  static const modelUrl =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin';

  static const _windowsZipUrl =
      'https://github.com/ggml-org/whisper.cpp/releases/download/$_whisperVersion/whisper-bin-x64.zip';
  static const _linuxTarUrl =
      'https://github.com/ggml-org/whisper.cpp/releases/download/$_whisperVersion/whisper-bin-ubuntu-x64.tar.gz';

  static final ValueNotifier<bool> enabledNotifier = ValueNotifier(false);
  static bool get isEnabled => enabledNotifier.value;


  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    enabledNotifier.value = prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    enabledNotifier.value = value;
  }

  /// All voice-sync files (whisper binary, its libs, and the model) live
  /// under the app's fixed `packagefiles/Synchronizations` path — NOT
  /// getApplicationSupportDirectory(). The installer does not bundle
  /// anything here, so this directory won't exist on first run; every
  /// caller that touches it must create it on demand.
  static Future<Directory> get assetsDir async {
    final dir = Directory(sync_dependacies_path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> get binaryFile async {
    final dir = await assetsDir;
    final name = Platform.isWindows ? 'whisper-cli.exe' : 'whisper-cli';
    return File('${dir.path}/$name');
  }

  static Future<File> get modelFile async {
    final dir = await assetsDir;
    return File('${dir.path}/ggml-base.bin'); // was ggml-base.en.bin
  }

  static Future<bool> filesExist() async {
    if (Platform.isMacOS) {
      final found = await _findMacSystemBinary();
      final model = await modelFile;
      return found != null && await model.exists();
    }
    final bin = await binaryFile;
    final model = await modelFile;
    return await bin.exists() && await model.exists();
  }

  /// Looks for a Homebrew-installed whisper-cli on common paths / PATH.
  static Future<String?> _findMacSystemBinary() async {
    const candidates = [
      '/opt/homebrew/bin/whisper-cli',
      '/usr/local/bin/whisper-cli',
    ];
    for (final path in candidates) {
      if (await File(path).exists()) return path;
    }
    try {
      final result = await Process.run('which', ['whisper-cli']);
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim();
        if (path.isNotEmpty) return path;
      }
    } catch (_) {}
    return null;
  }

  /// Resolves the actual binary path to invoke, accounting for macOS's
  /// system-install case (no downloaded copy under our own assets dir).
  static Future<String> resolveBinaryPath() async {
    if (Platform.isMacOS) {
      final found = await _findMacSystemBinary();
      if (found == null) {
        throw Exception(
          'whisper-cli not found. Install it with: brew install whisper-cpp',
        );
      }
      return found;
    }
    return (await binaryFile).path;
  }

  static Future<void> ensureDownloaded({
    void Function(String label, double progress)? onProgress,
  }) async {
    // assetsDir creates packagefiles/Synchronizations if it doesn't exist —
    // safe to call unconditionally since the installer never bundles it.
    await assetsDir;

    if (Platform.isMacOS) {
      final found = await _findMacSystemBinary();
      if (found == null) {
        throw Exception(
          'No prebuilt speech engine is available for macOS. '
          'Please run "brew install whisper-cpp" in Terminal, then try again.',
        );
      }
    } else {
      final bin = await binaryFile;
      if (!await bin.exists()) {
        onProgress?.call('Downloading speech engine', 0);
        await _downloadAndExtractBinary(onProgress: onProgress);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', bin.path]);
        }
      }
    }

    final model = await modelFile;
    if (!await model.exists()) {
      await _download(
        modelUrl,
        model,
        'Downloading speech model',
        onProgress: onProgress,
      );
    }
  }

  static Future<void> _downloadAndExtractBinary({
    void Function(String label, double progress)? onProgress,
  }) async {
    final dir = await assetsDir;
    final isWindows = Platform.isWindows;
    final url = isWindows ? _windowsZipUrl : _linuxTarUrl;
    final archiveFile = File(
      '${dir.path}/${isWindows ? "whisper.zip" : "whisper.tar.gz"}',
    );

    await _download(
      url,
      archiveFile,
      'Downloading speech engine',
      onProgress: onProgress,
    );

    onProgress?.call('Extracting speech engine', 0.95);

    final bytes = await archiveFile.readAsBytes();
    late final Archive archive;
    if (isWindows) {
      archive = ZipDecoder().decodeBytes(bytes);
    } else {
      archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
    }

    // Flatten everything into assetsDir — the release archives sometimes
    // nest files under a subfolder (e.g. "Release/"), and whisper-cli needs
    // its DLLs/.so libs sitting next to it regardless of that structure.
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final outPath = '${dir.path}/${entry.name.split('/').last}';
      final outFile = File(outPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(entry.content as List<int>);
    }

    await archiveFile.delete();
  }

  static Future<void> _download(
    String url,
    File dest,
    String label, {
    void Function(String label, double progress)? onProgress,
  }) async {
    final tmp = File('${dest.path}.part');
    final client = HttpClient();
    IOSink? sink;

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          '$label failed (HTTP ${response.statusCode}) fetching $url',
        );
      }

      final total = response.contentLength;
      int received = 0;
      sink = tmp.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(label, received / total);
      }

      // Close BEFORE rename — renaming a file that still has an open write
      // handle is exactly the kind of thing that trips this same lock issue.
      await sink.close();
      sink = null;

      await tmp.rename(dest.path);
    } catch (e) {
      // Make sure the handle is released before we ever try to delete —
      // this ordering is what was missing and causing the lock error.
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }

      // Best-effort cleanup: on Windows, antivirus or a lingering OS-level
      // handle can still hold the file briefly even after close(). Don't let
      // a failed cleanup mask the real error that caused this catch.
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (cleanupError) {
        print("Warning: couldn't remove partial download $tmp: $cleanupError");
      }

      rethrow;
    } finally {
      client.close();
    }
  }
}
