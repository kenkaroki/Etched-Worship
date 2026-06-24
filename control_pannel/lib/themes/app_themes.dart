// ============================================================
//  app_themes.dart
//  Light-green app theme – Material 3
// ============================================================
//
//  USAGE in main.dart:
//
//    MaterialApp(
//      theme:      AppThemes.lightTheme,
//      darkTheme:  AppThemes.darkTheme,
//      themeMode:  ThemeMode.system,   // or .light / .dark
//      ...
//    )
//
//  ACCESS the colour scheme anywhere:
//    Theme.of(context).colorScheme.primary
//    AppColors.primary
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ----------------------------------------------------------------
//  AppColors – single source of truth for every colour token
// ----------------------------------------------------------------
class AppColors {
  AppColors._();

  // ── Primary green palette ──────────────────────────────────
  static const Color primary = Color(0xFF4CAF50); // Green 500
  static const Color primaryLight = Color(0xFF81C784); // Green 300
  static const Color primaryExtraLight = Color(0xFFC8E6C9); // Green 100
  static const Color primaryDark = Color(0xFF388E3C); // Green 700
  static const Color primaryDeep = Color(0xFF1B5E20); // Green 900

  // ── Secondary / accent ────────────────────────────────────
  static const Color secondary = Color(0xFF66BB6A); // Green 400
  static const Color tertiary = Color(0xFF26C6DA); // Cyan 400

  // ── Neutral grey scale ────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ── Semantic colours ──────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF0288D1);

  // ── Light-theme surfaces ──────────────────────────────────
  static const Color lightBackground = Color(0xFFF7FCF7); // faint green-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFECF5EC);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOnBackground = Color(0xFF1A2E1A);
  static const Color lightOutline = Color(0xFFB0BEC5);

  // ── Dark-theme surfaces ───────────────────────────────────
  static const Color darkBackground = Color(
    0xFF0F1A0F,
  ); // very dark green-black
  static const Color darkSurface = Color(0xFF1A2A1A);
  static const Color darkSurfaceVariant = Color(0xFF243524);
  static const Color darkOnSurface = Color(0xFFE6F0E6);
  static const Color darkOnBackground = Color(0xFFDCEFDC);
  static const Color darkOutline = Color(0xFF4A6A4A);
}

// ----------------------------------------------------------------
//  AppThemes – light and dark ThemeData
// ----------------------------------------------------------------
class AppThemes {
  AppThemes._();

  static const String _fontFamily = 'Roboto'; // swap to your custom font

  // ── Shared text theme builder ────────────────────────────
  static TextTheme _textTheme(Color display, Color body) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: display,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: display,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: display,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: display,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: display,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: display,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: display,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: display,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: display,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: body,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: body,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: body,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: body,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: body,
        letterSpacing: 1.15,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: body,
        letterSpacing: 1.5,
      ),
    );
  }

  // ================================================================
  //  LIGHT THEME
  // ================================================================
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryExtraLight,
      onPrimaryContainer: AppColors.primaryDeep,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD8F5D8),
      onSecondaryContainer: Color(0xFF1B3D1B),

      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCCF5FB),
      onTertiaryContainer: Color(0xFF003740),

      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      // ignore: deprecated_member_use – kept for Flutter <3.18 compat
      background: AppColors.lightBackground,
      onBackground: AppColors.lightOnBackground,

      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.grey600,

      outline: AppColors.lightOutline,
      outlineVariant: AppColors.grey300,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.grey900,
      onInverseSurface: AppColors.grey100,
      inversePrimary: AppColors.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(AppColors.lightOnBackground, AppColors.grey800),
      primaryTextTheme: _textTheme(Colors.white, AppColors.primaryExtraLight),

      // ── AppBar ────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: AppColors.primaryDark,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── Bottom navigation bar ─────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation bar (Material 3) ───────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryExtraLight,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark, size: 24);
          }
          return const IconThemeData(color: AppColors.grey500, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(color: AppColors.grey500, fontSize: 12);
        }),
        elevation: 8,
      ),

      // ── Navigation drawer ─────────────────────────────────
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryExtraLight,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ── Elevated button ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey500,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.4),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.grey400,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── Floating action button ────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Card ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        surfaceTintColor: AppColors.primaryExtraLight,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Input decoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.grey600, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey200, width: 1),
        ),
        prefixIconColor: AppColors.grey500,
        suffixIconColor: AppColors.grey500,
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),

      // ── Chip ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryExtraLight,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.grey200,
        labelStyle: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 2,
      ),

      // ── Dialog ────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.grey600,
        ),
      ),

      // ── Bottom sheet ──────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        elevation: 8,
        modalElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.grey300,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return AppColors.grey400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected))
            return AppColors.primaryLight;
          return AppColors.grey300;
        }),
      ),

      // ── Checkbox ──────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.grey400, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Radio ─────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return AppColors.grey400;
        }),
      ),

      // ── Slider ────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryExtraLight,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primaryDark,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
        trackHeight: 4,
      ),

      // ── Tab bar ───────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2.5),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ── Progress indicator ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryExtraLight,
        circularTrackColor: AppColors.primaryExtraLight,
      ),

      // ── List tile ─────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryExtraLight,
        selectedColor: AppColors.primaryDark,
        iconColor: AppColors.grey600,
        textColor: AppColors.lightOnSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // ── Icons ─────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.grey700, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

      // ── Tooltip ───────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.grey800.withOpacity(0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Snack bar ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ── Popup menu ────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 14,
        ),
      ),

      // ── Drawer ────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        width: 280,
      ),

      // ── Search bar ────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateProperty.all(
          AppColors.lightSurfaceVariant,
        ),
        elevation: MaterialStateProperty.all(0),
        hintStyle: MaterialStateProperty.all(
          const TextStyle(color: AppColors.grey500),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: AppColors.lightOnSurface),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // ================================================================
  //  DARK THEME
  // ================================================================
  static ThemeData get darkTheme {
    const darkError = Color(0xFFCF6679);
    const darkSecondary = Color(0xFF90C990);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,

      primary: AppColors.primaryLight, // lighter for contrast on dark bg
      onPrimary: AppColors.primaryDeep,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryExtraLight,

      secondary: darkSecondary,
      onSecondary: Color(0xFF00390A),
      secondaryContainer: Color(0xFF1B5D1B),
      onSecondaryContainer: Color(0xFFA8F5A8),

      tertiary: Color(0xFF80DEEA),
      onTertiary: Color(0xFF003740),
      tertiaryContainer: Color(0xFF004E5A),
      onTertiaryContainer: Color(0xFFCCF5FB),

      error: darkError,
      onError: Color(0xFF690019),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // ignore: deprecated_member_use
      background: AppColors.darkBackground,
      onBackground: AppColors.darkOnBackground,

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFA0BBA0),

      outline: AppColors.darkOutline,
      outlineVariant: Color(0xFF3A5A3A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.grey100,
      onInverseSurface: AppColors.grey800,
      inversePrimary: AppColors.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(
        AppColors.darkOnBackground,
        AppColors.darkOnSurface,
      ),
      primaryTextTheme: _textTheme(
        AppColors.primaryLight,
        AppColors.primaryExtraLight,
      ),

      // ── AppBar ────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.darkBackground,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
        actionsIconTheme: const IconThemeData(color: AppColors.darkOnSurface),
      ),

      // ── Bottom navigation bar ─────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.grey500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation bar (Material 3) ───────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryDark,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryExtraLight,
              size: 24,
            );
          }
          return const IconThemeData(color: AppColors.grey500, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(color: AppColors.grey500, fontSize: 12);
        }),
        elevation: 8,
      ),

      // ── Navigation drawer ─────────────────────────────────
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryDark,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ── Elevated button ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.primaryExtraLight,
          disabledBackgroundColor: AppColors.grey800,
          disabledForegroundColor: AppColors.grey600,
          elevation: 2,
          shadowColor: Colors.black38,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.grey600,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // ── Floating action button ────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.primaryExtraLight,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Card ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: AppColors.primaryDark,
        elevation: 2,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Input decoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey700, width: 1),
        ),
        prefixIconColor: AppColors.grey500,
        suffixIconColor: AppColors.grey500,
        errorStyle: const TextStyle(color: darkError, fontSize: 12),
      ),

      // ── Chip ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryDark,
        disabledColor: AppColors.grey800,
        labelStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.primaryExtraLight,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        brightness: Brightness.dark,
        elevation: 0,
        pressElevation: 2,
      ),

      // ── Dialog ────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.grey400,
        ),
      ),

      // ── Bottom sheet ──────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        elevation: 8,
        modalElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.grey700,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        // MaterialStateProperty deprecated -> use WidgetStateProperty
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected))
            return AppColors.primaryLight;
          return AppColors.grey600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected))
            return AppColors.primaryDark;
          return AppColors.grey800;
        }),
      ),

      // ── Checkbox ──────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        // Checkbox theme - replace deprecated MaterialStateProperty
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected))
            return AppColors.primaryLight;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primaryDeep),
        side: const BorderSide(color: AppColors.grey600, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Radio ─────────────────────────────────────────────
      radioTheme: RadioThemeData(
        // Radio theme - replace deprecated MaterialStateProperty
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected))
            return AppColors.primaryLight;
          return AppColors.grey600;
        }),
      ),

      // ── Slider ────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.primaryDark,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withOpacity(0.12),
        valueIndicatorColor: AppColors.primaryLight,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.primaryDeep),
        trackHeight: 4,
      ),

      // ── Tab bar ───────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2.5),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ── Progress indicator ────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.primaryDark,
        circularTrackColor: AppColors.primaryDark,
      ),

      // ── List tile ─────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryDark.withOpacity(0.45),
        selectedColor: AppColors.primaryLight,
        iconColor: AppColors.grey400,
        textColor: AppColors.darkOnSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // ── Icons ─────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.grey400, size: 24),
      primaryIconTheme: const IconThemeData(
        color: AppColors.primaryLight,
        size: 24,
      ),

      // ── Tooltip ───────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.grey100.withOpacity(0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AppColors.grey900, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Snack bar ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 14,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ── Popup menu ────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 14,
        ),
      ),

      // ── Drawer ────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        width: 280,
      ),

      // ── Search bar ────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: MaterialStateProperty.all(
          AppColors.darkSurfaceVariant,
        ),
        elevation: MaterialStateProperty.all(0),
        hintStyle: MaterialStateProperty.all(
          const TextStyle(color: AppColors.grey500),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: AppColors.darkOnSurface),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
