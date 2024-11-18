// ======================================================================
// File: main.dart
// Description: Entry point of the BoaBox application. Initializes
//              providers, sets up logging, and builds the main
//              application widget.
// Author: Your Name
// Date: 2024-11-07
// ======================================================================


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:boabox/pages/home_page/home_page.dart';
import 'package:boabox/pages/library_page/library_page.dart';
import 'package:boabox/pages/settings_page/settings_page.dart';
import 'package:boabox/providers/game_provider.dart';
import 'package:boabox/providers/settings_provider.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/utils/theme/theme_builder.dart';


/// The entry point of the BoaBox application.
///
/// Initializes necessary services, sets up providers, and runs the app.
void main() async {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  logger.i("Application Started");
  logger.i("Using SQLite With Version: ${sqlite3.version}");

  test();

  // Initialize SettingsProvider with user settings
  final settingsProvider = await SettingsProvider.withUserSettings();

  // Initialize GameProvider with library directories from settings
  final gameProvider = GameProvider.withLibraryDirectories(settingsProvider.libraryDirectories);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => gameProvider),
      ],
      child: const BoaBox(),
    ),
  );
}


/// A StatelessWidget that serves as the root of the BoaBox application.
///
/// It wraps the [MainPage] with [ThemeBuilder] to apply theming based on user settings.
class BoaBox extends StatelessWidget {
  const BoaBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeBuilder(
      child: MainPage(),
    );
  }
}


/// The main page of the BoaBox application containing the bottom navigation.
///
/// Manages navigation between [HomePage], [LibraryPage], and [SettingsPage].
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}


/// The state class for [MainPage].
///
/// Handles the current selected page index and updates it based on user interactions.
class MainPageState extends State<MainPage> {
  static const List<Widget> _pages = [
    HomePage(),
    LibraryPage(),
    SettingsPage(),
  ];

  static const List<Widget> _destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.clear_all_rounded), label: 'Library'),
    NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
  ];

  void _onItemTapped(int index) {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.selectedPageIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    logger.t("Scaffold rebuild.");
    return Scaffold(
      body: IndexedStack(
        index: settingsProvider.selectedPageIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: settingsProvider.selectedPageIndex,
        destinations: _destinations,
      ),
    );
  }
}

void test() async {

}
