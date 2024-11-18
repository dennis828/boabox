// ======================================================================
// File: theme_helper.dart
// Description: Provides utilities for creating custom TextThemes using
//              Google Fonts.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Creates a customized [TextTheme] using specified body and display fonts.
///
/// The [createTextTheme] function utilizes Google Fonts to generate a [TextTheme]
/// based on the provided [bodyFont] and [displayFont]. It merges the body and display
/// text themes to ensure consistency across different text styles.
///
/// - **bodyFont**: The font to be used for body text.
/// - **displayFont**: The font to be used for display text.
/// - **baseTextTheme**: The base [TextTheme] to apply the fonts to.
///
/// Returns a customized [TextTheme].
TextTheme createTextTheme(String bodyFont, String displayFont, TextTheme baseTextTheme) {
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFont, baseTextTheme);
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(displayFont, baseTextTheme);
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}


/// A helper class for managing custom Material Design themes.
///
/// The [CustomMaterialTheme] class provides methods to generate [ThemeData]
/// instances for light and dark themes based on a provided [TextTheme].
class CustomMaterialTheme {
  final TextTheme textTheme;

  CustomMaterialTheme(this.textTheme);

  /// Generates a [ThemeData] configured for a light theme.
  ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: textTheme,
      // Define additional light theme properties here
    );
  }

  /// Generates a [ThemeData] configured for a dark theme.
  ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: textTheme,
      // Define additional dark theme properties here
    );
  }
}
