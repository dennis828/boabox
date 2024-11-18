// ======================================================================
// File: settings_page.dart
// Description: Displays the settings page with various settings sections,
//              including UI settings and About information.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/pages/settings_page/widgets/about_section.dart';
import 'package:boabox/pages/settings_page/widgets/ui_section.dart';


/// A stateful widget that represents the Settings Page.
///
/// The [SettingsPage] widget displays a navigation rail with different settings sections
/// such as UI settings and About information. It adapts its layout based on screen size
/// to ensure responsiveness.
class SettingsPage extends StatefulWidget {
  /// Creates a [SettingsPage].
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

/// The state for the [SettingsPage] widget.
///
/// Manages the currently selected settings section and handles navigation.
class SettingsPageState extends State<SettingsPage> {
  /// The index of the currently selected settings section.
  int _selectedSettingsSectionIndex = 0;

  /// The list of navigation rail destinations.
  static const _navigationDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.remove_from_queue_rounded),
      label: Text('UI'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.help_outline_outlined),
      label: Text('About'),
    ),
  ];

  /// Builds the widget for the selected settings section.
  ///
  /// Returns the appropriate settings section widget based on the selected index.
  Widget _showSettingsSection() {
    switch (_selectedSettingsSectionIndex) {
      case 0:
        return const UiSection();

      case 1:
        return const AboutSection();

      default:
        return const UiSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NavigationRail(
          selectedIndex: _selectedSettingsSectionIndex,
          groupAlignment: 0,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedSettingsSectionIndex = index;
            });
          },
          extended: true,
          indicatorColor: Theme.of(context).colorScheme.tertiaryContainer,
          destinations: _navigationDestinations,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const VerticalDivider(
            thickness: 2,
            width: 1,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _showSettingsSection(),
          ),
        ),
      ],
    );
  }
}
