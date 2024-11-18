// ======================================================================
// File: theme_builder.dart
// Description: Builds and provides the application's theme.
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:boabox/providers/settings_provider.dart';
import 'package:boabox/utils/theme/app_theme.dart';
import 'package:boabox/utils/theme/theme_helper.dart';


/// A widget that builds the application's theme based on the current settings.
///
/// The [ThemeBuilder] listens to changes in the [SettingsProvider] and updates the
/// application's theme accordingly. It supports system default, light, and dark themes.
class ThemeBuilder extends StatelessWidget {
  /// The child widget that will be wrapped with the theme.
  final Widget child;

  /// Creates a [ThemeBuilder] with the specified [child].
  const ThemeBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, childWidget) {
        // Determine the current brightness based on ThemeType
        Brightness brightness;
        switch (settingsProvider.currentThemeType) {
          case ThemeType.systemDefault:
            brightness = MediaQuery.of(context).platformBrightness;
            break;
          case ThemeType.light:
            brightness = Brightness.light;
            break;
          case ThemeType.dark:
            brightness = Brightness.dark;
            break;
        }

        // Get the base TextTheme from the current theme
        TextTheme baseTextTheme = Theme.of(context).textTheme;

        // Create the custom TextTheme using theme_helper.dart
        TextTheme customTextTheme = createTextTheme(
          "Merriweather",
          "Chakra Petch",
          baseTextTheme,
        );

        // Initialize your custom AppTheme
        AppTheme appTheme = AppTheme(customTextTheme);

        // Select the appropriate ThemeData based on brightness and ThemeType
        ThemeData themeData;

        if (brightness == Brightness.light) {
          themeData = appTheme.light();
        } else {
          themeData = appTheme.dark();
        }

        // You can extend this to handle medium and high contrast themes
        // based on additional settings if required

        return MaterialApp(
          title: 'BoaBox',
          theme: themeData,
          home: child,
        );
      },
      child: child, // Pass the child widget to be used as home
    );
  }
}
