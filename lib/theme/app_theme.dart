import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6AAB64);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF757575);

  // Tailles de police standardisées
  static const double fontSizeXSmall = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeNormal = 14;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 20;

  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeMedium,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeNormal,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSmall,
        color: secondaryTextColor,
      ),
    ),
  );

  // Pour la rétrocompatibilité
  static ThemeData get theme => lightTheme;
} 