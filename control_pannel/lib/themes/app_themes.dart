import 'package:flutter/material.dart';

class AppThemes {
  // Light Colors
  static const Color queueLight = Color.fromARGB(255, 178, 169, 169);
  static const Color appbarLight = Colors.redAccent;
  static const Color selectedTextLight = Colors.red;
  static const Color coloredTextLight = Colors.pinkAccent;
  static const Color containersCardsLight = Colors.grey;
  static const Color coloredIconLight = Color.fromARGB(255, 236, 153, 147);

  // Dark Colors
  static const Color queueDark = Color.fromARGB(255, 35, 34, 34);
  static const Color appbarDark = Color.fromARGB(255, 74, 1, 1);
  static const Color selectedTextDark = Color.fromARGB(255, 107, 10, 3);
  static const Color coloredTextDark = Color.fromARGB(255, 105, 1, 35);

  // Public ThemeData
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: appbarLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appbarLight,
      brightness: Brightness.light,
      primary: appbarLight,
      secondary: coloredTextLight,
      background: Colors.white,
      surface: containersCardsLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: appbarLight,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appbarLight,
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    scaffoldBackgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: coloredIconLight),
    cardColor: containersCardsLight,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: appbarDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appbarDark,
      brightness: Brightness.dark,
      primary: appbarDark,
      secondary: coloredTextDark,
      background: queueDark,
      surface: Color(0xFF1F1F1F),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: appbarDark,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appbarDark,
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    scaffoldBackgroundColor: queueDark,
    iconTheme: const IconThemeData(color: Colors.white70),
    cardColor: Color(0xFF2A2A2A),
  );
}
