// ======================================================================
// File: user_app_settings.dart
// Description: Data model for user application settings, including
//              UI preferences and library directories.
//
// Author: dennis828
// Date: 2024-11-13
// ======================================================================

import 'package:boabox/providers/settings_provider.dart';

/// Represents the starting page in the application.
enum StartPage {
  home,
  library,
  settings,
}

/// Represents the action to perform when interacting with the banner.
enum BannerAction {
  openLibraryPage,
  startGame,
}


/// A data model for user application settings, including UI preferences
/// and library directories.
class UserAppSettings {
  /// The starting page of the application.
  StartPage startPage;

  /// The default theme of the application.
  ThemeType defaultTheme;

  /// The action performed when interacting with the banner on the home page.
  BannerAction bannerAction;

  /// Enables or disables internet recommendations on the home page.
  bool enableInternetRecommendations;

  /// List of directories where the games are located.
  List<String> libraryDirectories;


  /// Creates a [UserAppSettings] instance with the given properties.
  ///
  /// All parameters are optional and have default values.
  UserAppSettings(
    {this.startPage = StartPage.home,
    this.defaultTheme = ThemeType.dark,
    this.bannerAction = BannerAction.openLibraryPage,
    this.enableInternetRecommendations = true,
    List<String>? libraryDirectories}
  ) : libraryDirectories = libraryDirectories ?? [];



  /// Converts the [UserAppSettings] instance to a map suitable for database storage.
  Map<String, dynamic> toMap() {
    return {
      "key": 42, // unique identifier in the database
      "startPage": startPage.index,
      "defaultTheme": defaultTheme.index,
      "bannerAction": bannerAction.index,
      "enableInternetRecommendations": enableInternetRecommendations
          ? 1
          : 0, // convert to int for storage in db
      "libraryDirectories": _serializeLibraryDirectories(libraryDirectories)
    };
  }

  /// Creates a [UserAppSettings] instance from a map.
  ///
  /// Throws a [FormatException] if the map contains invalid data.
  factory UserAppSettings.fromMap(Map<String, dynamic> map) {
    return UserAppSettings(
      startPage: StartPage.values[map["startPage"]],
      defaultTheme: map["defaultTheme"] == null
        ? ThemeType.dark
        : ThemeType.values[map["defaultTheme"]],
      bannerAction: map["bannerAction"] == null
        ? BannerAction.openLibraryPage
        : BannerAction.values[map["bannerAction"]],
      enableInternetRecommendations:
        map["enableInternetRecommendations"] == 1 ? true : false,
      libraryDirectories: _parseLibraryDirectories(map["enableInternetRecommendations"])
    ); 
  }

  /// Creates a copy of this [UserAppSettings] with the given fields replaced with new values.
  // UserAppSettings copyWith({
  //   StartPage? startPage,
  //   ThemeType? defaultTheme,
  //   BannerAction? bannerAction,
  //   bool? enableInternetRecommendations,
  //   List<String>? libraryDirectories,
  // }) {
  //   return UserAppSettings(
  //     startPage: startPage ?? this.startPage,
  //     defaultTheme: defaultTheme ?? this.defaultTheme,
  //     bannerAction: bannerAction ?? this.bannerAction,
  //     enableInternetRecommendations: enableInternetRecommendations ?? this.enableInternetRecommendations,
  //     libraryDirectories: libraryDirectories ?? List.from(this.libraryDirectories),
  //   );
  // }

  /// Parses the library directories from a serialized string.
  ///
  /// Expects the directories to be joined by `<*>`.
  static List<String> _parseLibraryDirectories(String? serialized) {
    // "<*>" is used, because these characters can not occur in a path
    if (serialized == null || serialized.isEmpty) return [];
    return serialized.split('<*>').where((dir) => dir.isNotEmpty).toList();
  }

  /// Serializes the library directories into a single string separated by `<*>`.
  static String _serializeLibraryDirectories(List<String> directories) {
    return directories.join('<*>');
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserAppSettings &&
        other.startPage == startPage &&
        other.defaultTheme == defaultTheme &&
        other.bannerAction == bannerAction &&
        other.enableInternetRecommendations == enableInternetRecommendations &&
        _listEquals(other.libraryDirectories, libraryDirectories);
  }

  @override
  int get hashCode {
    return Object.hash(
      startPage,
      defaultTheme,
      bannerAction,
      enableInternetRecommendations,
      Object.hashAll(libraryDirectories),
    );
  }

  /// Helper method to compare two lists for equality.
  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
