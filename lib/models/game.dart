// ======================================================================
// File: game.dart
// Description: This file contains the logic for the game class that
//              represents games and their associated properties and
//              user settings.
//
// Author: dennis828
// Date: 2024-11-16
// ======================================================================

import 'dart:io';

import 'package:boabox/models/user_game_settings.dart';
import 'package:boabox/services/game_discovery/vndb_properties.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/services/snackbar_service/snackbar_service.dart';


/// Represents a game with its associated properties and user settings.
class Game {
  // The following properties are retrieved by indexing the file system.

  /// The name of the executable.
  final String appTitle;

  /// The URI path to the root folder of the game.
  final String uri;

  /// Indicates if the game contains a executable for macOS.
  final bool isMac;

  /// Indicates if the game contains a executable for Unix.
  final bool isUnix;

  /// Indicates if the game contains a executable for Windows.
  final bool isWin;

  /// The version of the game, if specified in the root folder.
  final String? version;

  // The following properties are retrieved by indexing the file system.

  /// The properties retrieved from the vndb API associated with the game,
  /// if available.
  VndbProperties? vndbProperties;

  /// The user-specific settings for the game.
  UserGameSettings userGameSettings;

  /// Creates a [Game] instance with the given properties.
  Game(
      {required this.appTitle,
      required this.uri,
      required this.isMac,
      required this.isUnix,
      required this.isWin,
      this.version,
      this.vndbProperties,
      required this.userGameSettings});

  /// Creates a [Game] instance with data from the vndb API in one go.
  ///
  /// Fetches [VndbProperties] from the API based on the provided [appTitle].
  static Future<Game> fromVndbData({
    required String appTitle,
    required String uri,
    required bool isMac,
    required bool isUnix,
    required bool isWin,
    String? version,
  }) async {
    final properties = await VndbProperties.fromApi(appTitle: appTitle);
    return Game(
        appTitle: appTitle,
        uri: uri,
        isMac: isMac,
        isUnix: isUnix,
        isWin: isWin,
        version: version,
        vndbProperties: properties,
        userGameSettings: UserGameSettings());
  }

  /// Creates a [Game] instance from SQLite database data.
  ///
  /// [vndbPropertiesString] is a JSON string representing VNDB properties.
  /// [userGameSettingsString] is a JSON string representing user settings.
  factory Game.fromDB(
      {required String appTitle,
      required String uri,
      required int isMac,
      required int isUnix,
      required int isWin,
      required String? version,
      required String? vndbPropertiesString,
      required String userGameSettingsString}) {
    return Game(
        appTitle: appTitle,
        uri: uri,
        isMac: isMac == 1 ? true : false,
        isUnix: isUnix == 1 ? true : false,
        isWin: isWin == 1 ? true : false,
        version: version,
        vndbProperties: vndbPropertiesString == null
            ? null
            : VndbProperties.fromJsonString(vndbPropertiesString),
        userGameSettings:
            UserGameSettings.fromJsonString(userGameSettingsString));
  }

  /// Converts the [Game] instance to a map suitable for database storage.
  Map<String, dynamic> toMap() {
    return {
      "appTitle": appTitle,
      "uri": uri,
      "isMac": isMac ? 1 : 0,
      "isUnix": isUnix ? 1 : 0,
      "isWin": isWin ? 1 : 0,
      "version": version,
      "vndbProperties": vndbProperties?.toJsonString(),
      "userGameSettings": userGameSettings.toJsonString()
    };
  }

  /// Returns the local data of the game which is the data gathered by indexing
  /// and the user settings.
  Game get localData => Game(
      appTitle: appTitle,
      uri: uri,
      isMac: isMac,
      isUnix: isUnix,
      isWin: isWin,
      version: version,
      userGameSettings: userGameSettings);

  /// Returns the vndb properties associated with the game.
  VndbProperties? get apiData => vndbProperties;

  /// Determines the application path based on the platform.
  ///
  /// Returns `null` if the platform is not supported.
  /// Returns `null` if the game does not support the platform.
  String? get appPath {
    if (Platform.isLinux && isUnix) {
      return userGameSettings.appUri ?? "$uri/$appTitle.sh";
    }
    if (Platform.isWindows && isWin) {
      return userGameSettings.appUri ?? "$uri\\$appTitle.exe";
    }
    return null;
  }

  /// Returns the display name of the game.
  ///
  /// Priority: user settings > vndb title > executable name.
  String get displayName {
    return userGameSettings.gameTitle ?? vndbProperties?.gameTitle ?? appTitle;
  }

  /// Launches the game application.
  ///
  /// Logs warnings if the platform is unsupported or the application does not exist.
  Future<void> launch() async {
    // TODO: Integrate Snackbar Messages!
    if (appPath == null) {
      logger.w("UI | Platform does not support game launching!");
      SnackbarService.showGameLaunchedError(0);
      return;
    }

    final file = File(appPath!);

    if (!file.existsSync()) {
      logger.w('UI | "$displayName" can not be launched in "$appPath".');
      SnackbarService.showGameLaunchedError(1, gameTitle: displayName, path: appPath);
      return;
    }

    await Process.start(appPath!, [], runInShell: true);
    logger.i('UI | Game "$displayName" launched with path "$appPath".');
    SnackbarService.showGameLaunchedSuccess(displayName);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // if both point to the same object in memory

    return other is Game &&
        other.appTitle == appTitle &&
        other.uri == uri &&
        other.isMac == isMac &&
        other.isWin == isWin &&
        other.isUnix == isUnix &&
        other.version == version &&
        other.vndbProperties == vndbProperties;
  }

  @override
  int get hashCode => Object.hash(
    appTitle,
    uri,
    isMac,
    isUnix,
    isWin,
    version,
    vndbProperties,
  );
}
