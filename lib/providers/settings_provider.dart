// ======================================================================
// File: settings_provider.dart
// Description: Manages user application settings, including theme
//              preferences, startup page selection,
//              internet recommendations, banner actions and 
//              library directory management.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:boabox/models/user_app_settings.dart';
import 'package:boabox/repositories/settings_repository_impl.dart';


/// Enumeration for different theme types.
enum ThemeType { systemDefault, light, dark }

/// Provider for managing user application settings.
///
/// The [SettingsProvider] handles various settings such as theme selection,
/// startup page, internet recommendations, banner actions, and library directories.
class SettingsProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const _numberOfPages = 3;

  /// The current user application settings.
  late final UserAppSettings _settings;
  
  /// The index of the currently selected startup page.
  late int _selectedPageIndex;

  /// Counter for new local game recommendations.
  int _newLocalGameRecommendations = 3;

  SettingsProvider._({required UserAppSettings settings}) {
    _settings = settings;
    _selectedPageIndex = _settings.startPage.index;

    WidgetsBinding.instance.addObserver(this);
  }

  /// Factory constructor to create an instance of [SettingsProvider] with user settings.
  ///
  /// Fetches settings from the repository and initializes the provider.
  static Future<SettingsProvider> withUserSettings() async {
    final settings = await SettingsRepositoryImpl().fetchSettings();
    return SettingsProvider._(settings: settings);
  }

  ///
  /// Getters
  ///

  /// Gets the current theme type.
  ThemeType get currentThemeType => _settings.defaultTheme;

  /// Gets the selected startup page index.
  int get selectedPageIndex => _selectedPageIndex;

  /// Gets the remaining number of new local game recommendations, decrements each time it's accessed.
  int get newLocalGameRecommendation => _newLocalGameRecommendations--;

  /// Gets the selected startup page as [StartPage].
  StartPage get selectedPageIndexDefault => _settings.startPage;

  /// Gets whether internet recommendations are enabled.
  bool get enableInternetRecommendations => _settings.enableInternetRecommendations;

  /// Gets the current banner action.
  BannerAction get bannerAction => _settings.bannerAction;

  /// Gets an unmodifiable list of library directories.
  List<String> get libraryDirectories => List.unmodifiable(_settings.libraryDirectories);


  ///
  /// Setters
  ///

  /// Sets the selected startup page index.
  ///
  /// Ensures the index is within valid range and saves the setting.
  set selectedPageIndex(int index) {
    _selectedPageIndex = index > _numberOfPages
        ? 0
        : index; // ensure the index is always in range
    notifyListeners();
    _saveSettingsToDb();
  }

  /// Sets the selected startup page as [StartPage].
  set selectedPageIndexDefault(StartPage page) {
    _settings.startPage = page;
    notifyListeners();
    _saveSettingsToDb();
  }

  /// Enables or disables internet recommendations.
  set enableInternetRecommendations(bool enable) {
    _settings.enableInternetRecommendations = enable;
    notifyListeners();
    _saveSettingsToDb();
  }

  /// Sets the banner action.
  set bannerAction(BannerAction action) {
    _settings.bannerAction = action;
    notifyListeners();
    _saveSettingsToDb();
  }

  /// Sets the library directories.
  ///
  /// Replaces the existing directories with the provided list.
  set libraryDirectories(List<String> directories) {
    _settings.libraryDirectories = directories;
    _saveSettingsToDb();
  }


  ///
  /// Methods
  ///

  /// Saves the current settings to the database.
  ///
  /// Handles any potential errors during the save operation.
  Future<void> _saveSettingsToDb() async {
    try {
      await SettingsRepositoryImpl().upsertSettings(_settings);
      logger.i('Settings saved successfully.');
    } catch (error, stackTrace) {
      logger.e('Failed to save settings.', error: error, stackTrace: stackTrace);
    }
  }

  /// Resets the new local game recommendations counter.
  ///
  /// Sets the counter to 3 and notifies listeners.
  void triggerNewLocalGameRecommendations() {
    // set to 3, each game recommendation will decrement the value by one as long the value is >0 they will load a new recommendation
    _newLocalGameRecommendations = 3;
    notifyListeners();
  }

  /// Updates the current theme type.
  ///
  /// Saves the new theme if it differs from the current one.
  void updateTheme(ThemeType theme) {
    if (_settings.defaultTheme != theme) {
      _settings.defaultTheme = theme;
      notifyListeners();
      _saveSettingsToDb();
    }
  }

  /// Wipes the settings database and reloads the settings.
  ///
  /// This action is irreversible.
  Future<void> wipeDatabase() async {
    try {
      await SettingsRepositoryImpl().wipeDatabase();
      _settings = await SettingsRepositoryImpl().fetchSettings();
      notifyListeners();
      logger.i('Database wiped and settings reloaded.');
    } catch (error, stackTrace) {
      logger.e('Failed to wipe database.', error: error, stackTrace: stackTrace);
    }
  }


  ///
  /// Lifecycle Methods
  ///

  @override
  void didChangePlatformBrightness() {
    if (_settings.defaultTheme == ThemeType.systemDefault) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
