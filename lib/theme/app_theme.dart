import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6AAB64);
  static const Color secondaryColor = Color(0xFF4A8244);
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color textColor = Color(0xFF2D3142);
  static const Color subtitleColor = Color(0xFF9BA3B2);
  static const Color successColor = Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFBAF17);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color surfaceColor = Colors.white;

  // Tailles de police standardisées
  static const double fontSizeXSmall = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeNormal = 14;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 20;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: fontSizeNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: TextStyle(
            fontSize: fontSizeNormal,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textColor,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textColor,
          fontSize: fontSizeNormal,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: fontSizeNormal,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: fontSizeNormal,
        ),
        bodyMedium: TextStyle(
          color: subtitleColor,
          fontSize: fontSizeSmall,
        ),
        bodySmall: TextStyle(
          color: subtitleColor,
          fontSize: fontSizeXSmall,
        ),
      ),
    );
  }
} 