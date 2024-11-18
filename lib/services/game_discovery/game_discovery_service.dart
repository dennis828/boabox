// ======================================================================
// File: game_discovery_service.dart
// Description: The GameDiscoveryService is responsible for indexing the
//              root directories for games and storing them in the
//              database.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:boabox/models/game.dart';
import 'package:boabox/models/user_game_settings.dart';
import 'package:boabox/repositories/game_repository_impl.dart';
import 'package:boabox/services/game_discovery/vndb_properties.dart';
import 'package:boabox/services/logger_service/logger_service.dart';


/// Enumeration for supported game platforms and their corresponding file extensions.
enum GamePlatform { mac, unix, windows }

/// GameDiscoveryService
///
/// Iterates through the root directories, discovers games based on file extensions,
/// and synchronizes them with the database.
class GameDiscoveryService {
  // final _os = Platform.operatingSystem;

  /// The list of directory paths to index.
  final List<String> _gameDirectories = [];

  /// The list of game fond in the directories that were searched
  final List<Game> games = [];

  // Handle for database transactions
  static final _gameRepository = GameRepositoryImpl(); 


  /// Creates an instance of [GameDiscoveryService].
  ///
  /// [directories]: The list of root directories to scan for games.
  GameDiscoveryService({required List<String> directories}) {
    _gameDirectories.addAll(directories);
  }

  
  /// Indexes the list of root directories to discover games.
  ///
  /// Scans each directory asynchronously and identifies games based on supported file extensions.
  Future<void> index() async {
    logger.i("Indexing The Following Directories: $_gameDirectories");
    for (var directoryString in _gameDirectories) {
      final root = Directory(directoryString);

      if (!root.existsSync()) {
        logger.w('Directory does not exist: "$directoryString". Skipping.');
        continue;
      }

      final directories = root.listSync().whereType<Directory>();

      try {
        for (var directory in directories) {
          final gameTitle = _getGameTitle(dir: directory);

          final isMac = _isMac(dir: directory);
          final isUnix = _isUnix(dir: directory);
          final isWin = _isWin(dir: directory);
          final version = _getVersion(dir: directory);

          final game = Game(
            appTitle: gameTitle,
            uri: directory.path,
            isMac: isMac,
            isUnix: isUnix,
            isWin: isWin,
            version: version,
            userGameSettings: UserGameSettings(),
          );

          games.add(game);
          logger.i('Found Game "${game.displayName}"\n  uri: "${game.uri}"\n  version: "${game.version}"');
        }
      }
      catch (error, stackTrace) {
        logger.e("Error accessing directory: $directoryString", error: error, stackTrace: stackTrace);
      }
    }
  }


  /// Synchronizes the discovered games with the database.
  ///
  /// Updates existing games, adds new ones, and removes games that no longer exist.
  Future<void> syncGames() async {
    // TODO: improve using sql querries
    // iterate through the list of games found by the gds
    // check for each game if the uri matches with a game in the list of the db:
    // II DOES MATCH: check if all the other properties match
    //      THEY DO MATCH:     remove the game from both lists
    //      THEY DO NOT MATCH: update the game in the db, then remove the game from both lists
    //
    // IT DOES NOT MATCH: add the game to the db
    //
    // if there are any entries in the db list after iterating throught it remove all of those game from the db
    final gamesInDB = await _gameRepository.fetchGames();
    final gamesFromGDS = List<Game>.from(games);
    for (var gameGDS in List<Game>.from(games)) {
      // iterate through copy to prevent element skipping caused by removing elements while iterating
      try {
        final gameDB = gamesInDB.firstWhere(
          // will fail if no element matches
          (gameDB) => gameDB.uri == gameGDS.uri,
        );
        if (gameDB.localData == gameGDS.localData) {
          gamesInDB.remove(gameDB);
          gamesFromGDS.remove(gameGDS);
          logger.t('Game "${gameGDS.appTitle}" Is Already Present In DB');
        } else {
          // update game in db
          logger.t('Updating Game "${gameGDS.appTitle}" In DB');

          ///TODO: UPDATE GAME ONLY WHEN LAST PROPERTIES UPDATE IS OLDER THEN ...
          // await _gameRepository.updateGame(gameGDS);
        }
      } catch (error) {
        // add game to db
        logger.t(
            'No Game "${gameGDS.appTitle}" With Matching URI "${gameGDS.uri}" In DB Found');
        logger.t('Adding Game "${gameGDS.appTitle}" To DB');
        gameGDS.vndbProperties = await VndbProperties.fromApi(
            appTitle: gameGDS
                .appTitle); // fetch the vndb properties before adding the game to the db
        await _gameRepository.addGame(gameGDS);
      }
    }

    if (gamesInDB.isNotEmpty) {
      for (var gameDB in gamesInDB) {
        // remove games from db
        await _gameRepository.deleteGame(gameDB.uri);
        logger.t(
            'Game "${gameDB.appTitle}" Was Not Found By GameDiscoveryService... Removing From DB');
      }
    }
  }


  ///
  /// Internal Helper Methods
  ///

  /// Verifies whether the game can run on mac
  bool _isMac({required Directory dir}) {
    // ToDo: Implement
    final files = dir.listSync().whereType<File>();
    for (var file in files) {
      final extension = path.extension(file.path);
      if (extension == ".mac") {
        return true;
      }
    }
    return false;
  }

  /// Verifies whether the game can run on linux
  bool _isUnix({required Directory dir}) {
    final files = dir.listSync().whereType<File>();
    for (var file in files) {
      final extension = path.extension(file.path);
      if (extension == ".sh") {
        return true;
      }
    }
    return false;
  }

  /// Verifies whether the game can run on windows
  bool _isWin({required Directory dir}) {
    final files = dir.listSync().whereType<File>();
    for (var file in files) {
      final extension = path.extension(file.path);
      if (extension == ".exe") {
        return true;
      }
    }
    return false;
  }

  /// Extracts the game title from the directory name.
  ///
  /// Assumes the directory name follows the format "GameTitle-Version".
  String _getGameTitle({required Directory dir}) {
    final dirName = path.basename(dir.path);
    return dirName.split("-")[0];
  }

  /// Extracts the version from the directory name if available.
  ///
  /// Returns the version string or `null` if not found.
  String? _getVersion({required Directory dir}) {
    final dirName = path.basename(dir.path);
    final versionRegex = RegExp(
        r'\d+\.\d+(?:\.\d+)?'); // Regex to match version numbers in `X.Y` or `X.Y.Z` format, where `X`, `Y`, and optional `Z` are numeric (e.g., `1.0`, `2.1.3`)
    final match = versionRegex.firstMatch(dirName)?[0];
    logger.t('Attempted To Find Version In "$dirName" With Result "$match".');
    return match; // return the match
  }
}
