import 'package:control_pannel/themes/app_themes.dart';
import 'package:flutter/material.dart';

import 'package:control_pannel/screens/create_display/create_display.dart';
import 'package:control_pannel/screens/Homes.dart';
import 'package:control_pannel/screens/music/music_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,

      routes: {
        '/' : (context) => Home(),
        '/AddDisplay':(context) => AddMedia(),
        '/Music': (context) => MusicPage()
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

