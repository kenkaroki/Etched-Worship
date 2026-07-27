import 'package:flutter/material.dart';
import 'package:control_pannel/services/audio_sync_settings_service.dart';
import 'package:control_pannel/themes/app_themes.dart';

class AudioSyncSettingsPage extends StatefulWidget {
  const AudioSyncSettingsPage({super.key});

  @override
  State<AudioSyncSettingsPage> createState() => _AudioSyncSettingsPageState();
}

class _AudioSyncSettingsPageState extends State<AudioSyncSettingsPage> {
  bool _downloading = false;
  String _downloadLabel = '';
  double _downloadProgress = 0;
  String? _error;

  Future<void> _onToggle(bool value) async {
    if (!value) {
      await AudioSyncSettingsService.setEnabled(false);
      setState(() {});
      return;
    }

    setState(() => _error = null);

    if (await AudioSyncSettingsService.filesExist()) {
      await AudioSyncSettingsService.setEnabled(true);
      setState(() {});
      return;
    }

    setState(() {
      _downloading = true;
      _downloadProgress = 0;
      _downloadLabel = 'Preparing download...';
    });

    try {
      await AudioSyncSettingsService.ensureDownloaded(
        onProgress: (label, progress) {
          if (!mounted) return;
          setState(() {
            _downloadLabel = label;
            _downloadProgress = progress;
          });
        },
      );
      await AudioSyncSettingsService.setEnabled(true);
    } catch (e) {
      setState(() => _error = "Couldn't download required files: $e");
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = AudioSyncSettingsService.isEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text("Audio Synchronization")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              const Text(
                "AI Voice Sync",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Audio Synchronization listens to what's being spoken or sung "
            "in the room and automatically jumps your active queue to the "
            "slide that best matches it — no clicker needed.\n\n"
            "It runs entirely on this device using a local speech engine, "
            "so nothing is streamed off your computer. Because it uses the "
            "microphone continuously while a queue is synced, only enable "
            "it when you intend to use it during a service.\n\n"
            "The first time you turn this on, a one-time download "
            "(~500MB) of the speech engine and model is required. After "
            "that it works fully offline.",
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: SwitchListTile(
              title: const Text(
                "Enable Audio Synchronization",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                enabled
                    ? "On — \"Sync with AI\" is shown on the Home queue panel"
                    : "Off — voice sync is hidden from the Home queue panel",
              ),
              value: enabled,
              activeColor: AppColors.primary,
              onChanged: _downloading ? null : _onToggle,
            ),
          ),
          if (_downloading) ...[
            const SizedBox(height: 20),
            Text(
              _downloadLabel,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress : null,
            ),
            const SizedBox(height: 6),
            Text(
              "${(_downloadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
