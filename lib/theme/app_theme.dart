import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6AAB64);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color textColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color secondaryColor = Color(0xFF4CAF50);

  // Tailles de police standardisées
  static const double fontSizeXSmall = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeNormal = 14;
  static const double fontSizeMedium = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 20;

  // Style uniforme pour le bouton Google
  static final ButtonStyle googleButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    side: const BorderSide(color: Colors.black12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    elevation: 0,
  );

  // Style uniforme pour le texte du bouton Google
  static const TextStyle googleButtonTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: const TextStyle(
        color: textColor,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
      ),
      toolbarHeight: 70,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.white,
      foregroundColor: primaryColor,
      centerTitle: true,
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

  static ThemeData get darkTheme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static String getLogoPath(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? 'assets/images/logo-blanc.png'
        : 'assets/images/logo-noir.png';
  }

  // Pour la rétrocompatibilité
  static ThemeData get theme => lightTheme;
} 