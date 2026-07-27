import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

import 'package:control_pannel/controllers/files.dart' show canvasExecutable;
import 'package:control_pannel/screens/settings/audio_sync_setttings.dart';
import 'package:control_pannel/screens/settings/upload_custom_backgrounds.dart';
import 'package:control_pannel/screens/settings/settings.dart';
import 'package:control_pannel/themes/app_themes.dart';
import 'package:control_pannel/screens/create_display/create_display.dart';
import 'package:control_pannel/screens/Homes.dart';
import 'package:control_pannel/screens/music/music_page.dart';

Process? _canvasProcess;

Future<void> _launchCanvas() async {
  try {
    _canvasProcess = await Process.start(
      canvasExecutable,
      [],
      mode: ProcessStartMode.normal,
    );

    _canvasProcess!.exitCode.then((code) {
      debugPrint("Canvas exited with code $code");
      _canvasProcess = null;
    });
  } catch (e) {
    debugPrint("Failed to launch canvas: $e");
  }
}

Future<void> _closeCanvas() async {
  if (_canvasProcess == null) return;

  try {
    _canvasProcess!.kill();

    // Wait briefly for it to terminate.
    await _canvasProcess!.exitCode.timeout(
      const Duration(seconds: 2),
      onTimeout: () => -1,
    );
  } catch (e) {
    debugPrint("Failed to close canvas: $e");
  }

  _canvasProcess = null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await _launchCanvas();

  windowManager.setPreventClose(true);
  windowManager.addListener(_WindowListener());

  runApp(const MyApp());
}

class _WindowListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    await _closeCanvas();
    await windowManager.destroy();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => Home(),
        '/AddDisplay': (context) => AddMedia(),
        '/Music': (context) => MusicPage(),
        '/settings': (context) => SettingsPage(),
        '/custom-background-upload': (context) => CustomBackgroundUploadPage(),
        '/audio-sync-settings': (context) => AudioSyncSettingsPage(),
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
