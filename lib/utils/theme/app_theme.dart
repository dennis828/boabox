// ======================================================================
// File: app_theme.dart
// Description: Defines the [AppTheme] class for managing and generating
//              various Material Design color schemes for the
//              application.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import "package:flutter/material.dart";

// class AppTheme {
//   // Material Theme Builer / Generator:
//   //   -->  https://material-foundation.github.io/material-theme-builder/
//   static const Color text = Color(0xFFefe2e3);
//   static const Color background = Color(0xFF242020);
//   static const Color primary = Color(0xFF6467d4);
//   static const Color secondary = Color(0xFF3f6367);
//   static const Color accent = Color(0xFF7b91b1);

//   static const Color warning = Color(0xFFd49c64);
//   static const Color error = Color(0xFFd46464);

//   static const String displayFont = "Chakra Petch";
//   static const String bodyFont = "Merriweather";
// }



/// Manages and generates [ThemeData] instances based on predefined [ColorScheme]s.
///
/// The [AppTheme] class provides methods to retrieve different theme variations
/// such as light, dark, and their respective contrast levels.
class AppTheme {
  final TextTheme textTheme;

  const AppTheme(this.textTheme);

  // Light Theme Schemes
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff575992),
      surfaceTint: Color(0xff575992),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe1e0ff),
      onPrimaryContainer: Color(0xff13144b),
      secondary: Color(0xff006971),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9df0f9),
      onSecondaryContainer: Color(0xff002023),
      tertiary: Color(0xff39608f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd3e4ff),
      onTertiaryContainer: Color(0xff001c38),
      error: Color(0xff904a49),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad8),
      onErrorContainer: Color(0xff3b080b),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff1a1c20),
      onSurfaceVariant: Color(0xff44474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffc0c1ff),
      primaryFixed: Color(0xffe1e0ff),
      onPrimaryFixed: Color(0xff13144b),
      primaryFixedDim: Color(0xffc0c1ff),
      onPrimaryFixedVariant: Color(0xff3f4178),
      secondaryFixed: Color(0xff9df0f9),
      onSecondaryFixed: Color(0xff002023),
      secondaryFixedDim: Color(0xff81d4dd),
      onSecondaryFixedVariant: Color(0xff004f55),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff001c38),
      tertiaryFixedDim: Color(0xffa3c9fe),
      onTertiaryFixedVariant: Color(0xff1e4876),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  // Medium Contrast Light Scheme
  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3b3d74),
      surfaceTint: Color(0xff575992),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6e6faa),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff004b50),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff238088),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff194471),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5177a7),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff6e2f2f),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffaa5f5e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff1a1c20),
      onSurfaceVariant: Color(0xff40434a),
      outline: Color(0xff5c5f67),
      outlineVariant: Color(0xff787a83),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xff41427a),
      primaryFixed: Color(0xff6e6faa),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff55578f),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff238088),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00666e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5177a7),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff375e8c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  // High Contrast Light Scheme
  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1a1b51),
      surfaceTint: Color(0xff575992),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff3b3d74),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff00272a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff004b50),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002343),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff194471),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff440f11),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff6e2f2f),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff21242b),
      outline: Color(0xff40434a),
      outlineVariant: Color(0xff40434a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3036),
      inversePrimary: Color(0xffeceaff),
      primaryFixed: Color(0xff3b3d74),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff25265c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff004b50),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003237),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff194471),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff002e55),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  // Dark Theme Schemes
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc0c1ff),
      surfaceTint: Color(0xffc0c1ff),
      onPrimary: Color(0xff292a60),
      primaryContainer: Color(0xff3f4178),
      onPrimaryContainer: Color(0xffe1e0ff),
      secondary: Color(0xff81d4dd),
      onSecondary: Color(0xff00363b),
      secondaryContainer: Color(0xff004f55),
      onSecondaryContainer: Color(0xff9df0f9),
      tertiary: Color(0xffa3c9fe),
      onTertiary: Color(0xff00315b),
      tertiaryContainer: Color(0xff1e4876),
      onTertiaryContainer: Color(0xffd3e4ff),
      error: Color(0xffffb3b1),
      onError: Color(0xff571d1e),
      errorContainer: Color(0xff733333),
      onErrorContainer: Color(0xffffdad8),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff575992),
      primaryFixed: Color(0xffe1e0ff),
      onPrimaryFixed: Color(0xff13144b),
      primaryFixedDim: Color(0xffc0c1ff),
      onPrimaryFixedVariant: Color(0xff3f4178),
      secondaryFixed: Color(0xff9df0f9),
      onSecondaryFixed: Color(0xff002023),
      secondaryFixedDim: Color(0xff81d4dd),
      onSecondaryFixedVariant: Color(0xff004f55),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff001c38),
      tertiaryFixedDim: Color(0xffa3c9fe),
      onTertiaryFixedVariant: Color(0xff1e4876),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1c20),
      surfaceContainer: Color(0xff1e2025),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  // Medium Contrast Dark Scheme
  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc5c6ff),
      surfaceTint: Color(0xffc0c1ff),
      onPrimary: Color(0xff0d0d45),
      primaryContainer: Color(0xff8a8bc8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff85d8e1),
      onSecondary: Color(0xff001a1c),
      secondaryContainer: Color(0xff479da5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffaacdff),
      onTertiary: Color(0xff00172f),
      tertiaryContainer: Color(0xff6d93c5),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffb9b7),
      onError: Color(0xff340407),
      errorContainer: Color(0xffcb7a79),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xfffbfaff),
      onSurfaceVariant: Color(0xffc8cad4),
      outline: Color(0xffa0a2ac),
      outlineVariant: Color(0xff80838c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff41427a),
      primaryFixed: Color(0xffe1e0ff),
      onPrimaryFixed: Color(0xff070641),
      primaryFixedDim: Color(0xffc0c1ff),
      onPrimaryFixedVariant: Color(0xff2f3066),
      secondaryFixed: Color(0xff9df0f9),
      onSecondaryFixed: Color(0xff001416),
      secondaryFixedDim: Color(0xff81d4dd),
      onSecondaryFixedVariant: Color(0xff003d42),
      tertiaryFixed: Color(0xffd3e4ff),
      onTertiaryFixed: Color(0xff001227),
      tertiaryFixedDim: Color(0xffaacdff),
      onTertiaryFixedVariant: Color(0xff043764),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1c20),
      surfaceContainer: Color(0xff1e2025),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  // High Contrast Dark Scheme
  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffdf9ff),
      surfaceTint: Color(0xffc0c1ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc5c6ff),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffeffdff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff85d8e1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffafaff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffaacdff),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffb9b7),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffbfaff),
      outline: Color(0xffc8cad4),
      outlineVariant: Color(0xffc8cad4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff222459),
      primaryFixed: Color(0xffe6e4ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc5c6ff),
      onPrimaryFixedVariant: Color(0xff0d0d45),
      secondaryFixed: Color(0xffa1f4fe),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff85d8e1),
      onSecondaryFixedVariant: Color(0xff001a1c),
      tertiaryFixed: Color(0xffdae8ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffaacdff),
      onTertiaryFixedVariant: Color(0xff00172f),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1c20),
      surfaceContainer: Color(0xff1e2025),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  // Method to get ThemeData based on ColorScheme
  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  // Light Theme
  ThemeData light() {
    return theme(lightScheme());
  }

  // Light Medium Contrast
  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  // Light High Contrast
  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  // Dark Theme
  ThemeData dark() {
    return theme(darkScheme());
  }

  // Dark Medium Contrast
  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  // Dark High Contrast
  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  // Extended Colors (Currently Empty)
  List<ExtendedColor> get extendedColors => [];
}

/// Represents extended color families with different contrast levels.
///
/// The [ExtendedColor] class encapsulates a seed color and its corresponding
/// variations across different theme contrasts.
class ExtendedColor {
  /// The seed color.
  final Color seed;

  /// The primary color value.
  final Color value;

  /// Color family for the light theme.
  final ColorFamily light;

  /// Color family for the light medium contrast theme.
  final ColorFamily lightHighContrast;

  /// Color family for the light high contrast theme.
  final ColorFamily lightMediumContrast;

  /// Color family for the dark theme.
  final ColorFamily dark;

  /// Color family for the dark high contrast theme.
  final ColorFamily darkHighContrast;

  /// Color family for the dark medium contrast theme.
  final ColorFamily darkMediumContrast;

  /// Creates an instance of [ExtendedColor].
  ///
  /// All parameters are required and define the color variations across themes.
  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

/// Represents a family of colors used within a specific theme.
///
/// The [ColorFamily] class holds a color and its variants for different UI elements.
class ColorFamily {
  /// The primary color.
  final Color color;

  /// The color used for text/icons on top of the primary color.
  final Color onColor;

  /// The container color related to the primary color.
  final Color colorContainer;

  /// The color used for text/icons on top of the color container.
  final Color onColorContainer;

  /// Creates an instance of [ColorFamily].
  ///
  /// All parameters are required and define the color relationships within the family.
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });
}
