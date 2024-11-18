// ======================================================================
// File: game_provider.dart
// Description: Manages game data, including loading, updating
//              and deleting games.
//
// Author: Your Name
// Date: 2024-11-17
// ======================================================================


import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/models/image64.dart';
import 'package:boabox/services/game_discovery/game_discovery_service.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/repositories/game_repository_impl.dart';

/// A provider that manages game data, including loading, updating, and deleting games.
class GameProvider extends ChangeNotifier {
  /// List of games that get exposed to the application
  List<Game> _games = [];

  /// List of directory paths the GameDiscoveryService will try to find games in.
  final List<String> _libraryDirectories = [];
  
  /// Instance of the GameDiscoveryService
  late GameDiscoveryService _gds;
  
  /// The game which is currently selected and displayed in the library.
  Game? _selectedGame;

  /// Whether the GameDiscoveryService is currently indexing the directories.
  bool _isLoading = false;

  GameProvider._();

  /// Creates a [GameProvider] with the provided library directories.
  ///
  /// Initializes the [GameDiscoveryService] and loads games.
  factory GameProvider.withLibraryDirectories(List<String> directories) {
    final gp = GameProvider._();
    gp.setLibraryDirectories(directories);
    gp._init();
    return gp;
  }


  /// Initializes the game provider by loading games.
  Future<void> _init() async {
    await loadGames();
  }

  /// Returns an unmodifiable view of the games list.
  List<Game> get games => _games;

  /// The currently selected game.
  Game? get selectedGame => _selectedGame;

  /// Indicates whether the provider is currently loading data.
  bool get isLoading => _isLoading;


  /// Sets the selected game and notifies listeners.
  set selectedGame(Game? game) {
    _selectedGame = game;
    logger.t('GameProvider has game "${game?.appTitle}" selected.');
    notifyListeners();
  }


  /// Adds library directories and initializes the [GameDiscoveryService].
  ///
  /// Notifies listeners after adding directories.
  void setLibraryDirectories(List<String> directories) { // TODO: possibly rename to addLibraryDirectories
    _libraryDirectories.addAll(directories);
    logger.i("GameProvider added ${directories.length} to GameDiscoveryService");
    _gds = GameDiscoveryService(directories: _libraryDirectories);
    resyncGames();
    notifyListeners();
  }


  /// Updates the selected game with the data provided
  Future<void> updateSelectedGame(
      {
      // String? appTitle,    // Game Properties --> makes no sense to update here, might add in the future if use case is found
      // String? uri,         // Game Properties --> makes no sense to update here, might add in the future if use case is found
      // bool? isMac,         // Game Properties --> makes no sense to update here, might add in the future if use case is found
      // bool? isUnix,        // Game Properties --> makes no sense to update here, might add in the future if use case is found
      // bool? isWin,         // Game Properties --> makes no sense to update here, might add in the future if use case is found
      // String? version,     // Game Properties --> makes no sense to update here, might add in the future if use case is found
      String? userGameTitle,    // UserGameSettings
      String? userAppUri,       // UserGameSettings
      Image64? userCoverImage,  // UserGameSettings
      Image64? userBannerImage, // UserGameSettings
      String? vndbGameTitle,                      // VndbProperties
      int? vndbDevelopmentStatus,                 // VndbProperties
      Image64? vndbCoverImage,                    // VndbProperties
      Image64? vndbBannerImage,                   // VndbProperties
      String? vndbDescription,                    // VndbProperties
      List<Map<String, dynamic>>? vndbTags,       // VndbProperties --> replaces the original list with the new one
      List<Map<String, String>>? vndbDevelopers,  // VndbProperties --> replaces the original list with the new one
      double? vndbRating,                         // VndbProperties
      List<String>? propertiesToReset}) async {
    if (_selectedGame == null) return;
    propertiesToReset ??= [];

    if (userGameTitle != null) {
      _selectedGame!.userGameSettings.gameTitle = userGameTitle;
    } else if (propertiesToReset.contains("userGameTitle")) {
      _selectedGame!.userGameSettings.gameTitle = null;
    }

    if (userAppUri != null) {
      _selectedGame!.userGameSettings.appUri = userAppUri;
    } else if (propertiesToReset.contains("userAppUri")) {
      _selectedGame!.userGameSettings.appUri = null;
    }

    if (userCoverImage != null) {
      _selectedGame!.userGameSettings.coverImage = userCoverImage;
    } else if (propertiesToReset.contains("userCoverImage")) {
      _selectedGame!.userGameSettings.coverImage = null;
    }

    if (userBannerImage != null) {
      _selectedGame!.userGameSettings.bannerImage = userBannerImage;
    } else if (propertiesToReset.contains("userBannerImage")) {
      _selectedGame!.userGameSettings.bannerImage = null;
    }

    if (vndbGameTitle != null) {
      _selectedGame!.vndbProperties?.gameTitle = vndbGameTitle;
    }

    if (vndbDevelopmentStatus != null) {
      _selectedGame!.vndbProperties?.developmentStatus = vndbDevelopmentStatus;
    }

    if (vndbCoverImage != null) {
      _selectedGame!.vndbProperties?.coverImage = vndbCoverImage;
    } else if (propertiesToReset.contains("vndbCoverImage")) {
      _selectedGame!.vndbProperties?.coverImage = null;
    }

    if (vndbBannerImage != null) {
      _selectedGame!.vndbProperties?.bannerImage = vndbBannerImage;
    } else if (propertiesToReset.contains("vndbBannerImage")) {
      _selectedGame!.vndbProperties?.bannerImage = null;
    }

    if (vndbTags != null) {
      _selectedGame!.vndbProperties?.tags.clear();
      _selectedGame!.vndbProperties?.tags.addAll(vndbTags);
    } else if (propertiesToReset.contains("vndbTags")) {
      _selectedGame!.vndbProperties?.tags.clear();
    }

    if (vndbDevelopers != null) {
      _selectedGame!.vndbProperties?.developers.clear();
      _selectedGame!.vndbProperties?.developers.addAll(vndbDevelopers);
    } else if (propertiesToReset.contains("vndbDevelopers")) {
      _selectedGame!.vndbProperties?.developers.clear();
    }

    if (vndbRating != null) {
      _selectedGame!.vndbProperties?.rating = vndbRating;
    } else if (propertiesToReset.contains("vndbRating")) {
      _selectedGame!.vndbProperties?.rating = null;
    }

    final int indexOfGameInGames =
        games.indexWhere((game) => game.uri == _selectedGame!.uri);

    if (indexOfGameInGames != -1) {
      games[indexOfGameInGames] = _selectedGame!;
    } else {
      logger.w('GameProvider has not found game "${_selectedGame!.displayName}" to update in games.');
    }

    logger.t('GameProvider has received update for "${_selectedGame!.displayName}".');

    notifyListeners();

    await GameRepositoryImpl().updateGame(_selectedGame!);
  }


  /// Deletes the selected game and its associated files.
  ///
  /// Notifies listeners after deletion.
  Future<void> deleteSelectedGame() async {
    if (_selectedGame == null) return;

    final directory = Directory(_selectedGame!.uri);

    if (!directory.existsSync()) {
      logger.w('Files for game "${_selectedGame!.displayName}" do not exit in "${_selectedGame!.uri}".');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Game files do not exist.")),
      // );
      return;
    }

    try {
      await directory.delete(recursive: true);
      logger.i('Deleted game files for "${_selectedGame!.appTitle}".');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Game files deleted successfully.")),
      // );

    } catch (error, stackTrace) {
      logger.e('Error deleting files for game "${_selectedGame!.appTitle}" in  "${_selectedGame!.uri}"', error: error, stackTrace: stackTrace);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Failed to delete game files.")),
      // );
      return;
    }

    GameRepositoryImpl().deleteGame(_selectedGame!.uri);

    _games.removeWhere((game) => game.uri == _selectedGame!.uri);
    logger.i('Removed "${_selectedGame!.displayName}" from games list.');

    _selectedGame = null;
    notifyListeners();
  }

  /// Returns a random game from the games list.
  Game? getRandomGame() {
    if (games.isEmpty) return null;
    final randomInt = Random().nextInt(games.length);
    return games.elementAt(randomInt);
  }

  /// Loads games from the repository and game discovery service.
  ///
  /// Sets [isLoading] to true while loading and notifies listeners upon completion.
  Future<void> loadGames() async {
    if (_games.isNotEmpty) return; // Prevent reloading
    _isLoading = true;
    notifyListeners();

    final gameRepository = GameRepositoryImpl();

    await _gds.index();
    await _gds.syncGames();

    // replace the list with a new list instance
    // this ensures downstream widgets are
    // guranteed to notice the change
    _games = List<Game>.from(await gameRepository.fetchGames());
    logger.i("GameProvider Received ${_games.length} Games");

    _isLoading = false;

    notifyListeners();
  }

  /// Resyncs the games by clearing the current list and loading again.
  void resyncGames() {
    _games.clear();
    loadGames();
  }
}
