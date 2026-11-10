import 'package:flutter/material.dart';
class AppColors {
  static const Color navy = Color(0xFF0B1B30);
  static const Color blue = Color(0xFF17386B);
  static const Color lime = Color(0xFFC6F135);
  static const Color background = Color(0xFFF3F5F9);
  static const Color border = Color(0xFFE1E6EE);
  static const Color muted = Color(0xFF5F6F86);
  static const Color text = Color(0xFF0B1B30);

  static const Color redBg = Color(0xFFFBDCDC);
  static const Color red = Color(0xFFB42318);
  static const Color amberBg = Color(0xFFFDEBCB);
  static const Color amberSoft = Color(0xFFFFF4DB);
  static const Color amber = Color(0xFF9A4A07);
  static const Color greenBg = Color(0xFFDDF3E4);
  static const Color green = Color(0xFF1E7B3C);
  static const Color infoBg = Color(0xFFE6EEF9);
  static const Color info = Color(0xFF2F5FA8);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF8795A9), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
      ),
    );
  }
}
