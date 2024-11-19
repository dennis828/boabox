// ======================================================================
// File: database_service.dart
// Description: Manages the SQLite database.
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/models/user_app_settings.dart';
import 'package:boabox/providers/settings_provider.dart';
import 'package:boabox/utils/database_path/database_path.dart';
import 'package:boabox/services/logger_service/logger_service.dart';


// SQLite Game Table:

// uri (Primary Key)   TEXT NOT NULL
// appTitle            TEXT NOT NULL
// isMac               BOOL NOT NULL
// isUnix              BOOL NOT NULL
// isWin               BOOL NOT NULL
// version             TEXT OR NULL
// VndbProperties      TEXT OR NULL

/// Exception thrown when the database is not initialized.
class DatabaseNotInitializedException implements Exception {
  final String message;
  DatabaseNotInitializedException([this.message = 'Database is not initialized.']);

  @override
  String toString() => 'DatabaseNotInitializedException: $message';
}


/// Service class for managing SQLite database operations.
class DatabaseService {
  /// The name of the database file.
  // static const String _dbName = 'database.db';

  /// Indicates if the database has been initialised.
  static bool _isInitialized = false;

  /// The SQLite database instance.
  late Database? _database;

  /// Used to prevent race conditions.
  /// If multiple parts of the application attempt to initialize the database simultaneously,
  /// this ensures that all callers receive the same future, preventing race conditions and redundant operations.
  Completer<void> _initCompleter = Completer<void>();

  /// Private constructor for singleton pattern.
  DatabaseService._internal();

  /// Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();

  /// Returns the singleton instance of [DatabaseService].
  factory DatabaseService() => _instance;

  /// Opens or creates the SQLite database.
  Future<void> initialize() async {
    if (_isInitialized) {
      return _initCompleter.future;
    }

    final String dbPath = await getDatabasePath();

    _database = sqlite3.open(dbPath); // open or create the database

    logger.i("Database file opened (and created).");

    _database!.execute('PRAGMA foreign_keys = ON;'); // enable foreign keys (if needed in future)

    _createTable(); // create the tables if they don't exist

    logger.i("Database initialisation is finished");

    _isInitialized = true;
    _initCompleter.complete();
  }

  /// create the game and settings table
  void _createTable() {
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS games (
        uri TEXT PRIMARY KEY NOT NULL,
        appTitle TEXT NOT NULL,
        isMac INTEGER NOT NULL,
        isUnix INTEGER NOT NULL,
        isWin INTEGER NOT NULL,
        version TEXT,
        vndbProperties TEXT,
        userGameSettings TEXT
      );
    ''');

    _database!.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key INTEGER PRIMARY KEY NOT NULL,
        startPage INTEGER NOT NULL,
        defaultTheme INTEGER NOT NULL,
        bannerAction INTEGER NOT NULL,
        enableInternetRecommendations INTEGER NOT NULL,
        libraryDirectories TEXT
      );
    ''');
  }

  ///
  /// CRUD Operations for Settings
  ///

  /// Inserts or updates [settings] in the database.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<void> upsertSettings(UserAppSettings settings) async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! can NOT update Settings!");
      throw DatabaseNotInitializedException();
    }

    final Map<String, dynamic> settingsMap = settings.toMap();

    final stmt = _database!.prepare('''
      INSERT INTO settings (
        key, startPage, defaultTheme, bannerAction, enableInternetRecommendations, libraryDirectories
      ) VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(key) DO UPDATE SET
        startPage = excluded.startPage,
        defaultTheme = excluded.defaultTheme,
        bannerAction = excluded.bannerAction,
        enableInternetRecommendations = excluded.enableInternetRecommendations,
        libraryDirectories = excluded.libraryDirectories;
    ''');

    try {
      stmt.execute([
        settingsMap['key'],
        settingsMap['startPage'],
        settingsMap['defaultTheme'],
        settingsMap['bannerAction'],
        settingsMap['enableInternetRecommendations'],
        settingsMap['libraryDirectories']
      ]);
      logger.i("Settings upserted successfully.");
    }
    catch (error, stackTrace) {
      logger.w("SQL transaction failed. Failed to upsert settings.", error: error, stackTrace: stackTrace);
      rethrow;
    }
    finally {
      stmt.dispose();
    }
  }


  /// Retrieves the user application settings from the database.
  ///
  /// Returns `null` if no settings are found.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<UserAppSettings?> getSettings() async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT get Settings!");
      throw DatabaseNotInitializedException();
    }

    final stmt = _database!.prepare('''
      SELECT key, startPage, defaultTheme, bannerAction, enableInternetRecommendations, libraryDirectories
      FROM settings
      WHERE key = ?;
    ''');

    try {
      final ResultSet result = stmt.select([42]);
      if (result.isEmpty) return null;
      final row = result.first;
      return UserAppSettings(
        startPage: StartPage.values[row["startPage"]],
        defaultTheme: ThemeType.values[row["defaultTheme"]],
        bannerAction: BannerAction.values[row["bannerAction"]],
        enableInternetRecommendations: row["enableInternetRecommendations"] == 1 ? true : false,
        libraryDirectories: row["libraryDirectories"] == "" ? [] : row["libraryDirectories"].split("<*>")); // prevent empty string in list
    }
    catch (error, stackTrace) {
      logger.e("DatabaseService: Failed to fetch settings.", error: error, stackTrace: stackTrace);
      rethrow;
    }
    finally {
      stmt.dispose();
    }
  }


  ///
  /// CRUD Operations for Games
  ///

  /// Inserts a new [game] into the database.
  ///
  /// Uses `INSERT OR IGNORE` to prevent duplicate entries based on the primary key.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
 Future<void> insertGame(Game game) async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT insert game!");
      throw DatabaseNotInitializedException();
    }
    final Map<String, dynamic> gameMap = game.toMap();

    final stmt = _database!.prepare('''
      INSERT OR IGNORE INTO games (
        uri, appTitle, isMac, isUnix, isWin, version, vndbProperties, userGameSettings
      ) VALUES (
        ?, ?, ?, ?, ?, ?, ?, ?
      );
    ''');

    _logSizeOfString(gameMap['vndbProperties']);

    try {
      stmt.execute([
        gameMap['uri'],
        gameMap['appTitle'],
        gameMap['isMac'],
        gameMap['isUnix'],
        gameMap['isWin'],
        gameMap['version'],
        gameMap['vndbProperties'],
        gameMap['userGameSettings']
      ]);

      logger.i("Game '${game.displayName}' inserted successfully into database.");
    } catch (error, stackTrace) {
      logger.w('Failed to insert game "${game.displayName}" into database.', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      stmt.dispose();
    }
  }


  /// Inserts multiple [games] into the database within a transaction.
  ///
  /// Uses `INSERT OR IGNORE` to prevent duplicate entries based on the primary key.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<void> insertGames(List<Game> games) async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT insert games!");
      throw DatabaseNotInitializedException();
    }

    final stmt = _database!.prepare('''
      INSERT OR IGNORE INTO games (
        uri, appTitle, isMac, isUnix, isWin, version, vndbProperties, userGameSettings
      ) VALUES (
        ?, ?, ?, ?, ?, ?, ?, ?
      );
    ''');

    _database!.execute('BEGIN TRANSACTION;');

    try {
      for (var game in games) {
        final Map<String, dynamic> gameMap = game.toMap();
        stmt.execute([
          gameMap['uri'],
          gameMap['appTitle'],
          gameMap['isMac'],
          gameMap['isUnix'],
          gameMap['isWin'],
          gameMap['version'],
          gameMap['vndbProperties'],
          gameMap['userGameSettings'],
        ]);
      }
      _database!.execute('COMMIT;');
      logger.i("${games.length} games were successfully inserted into the database.");
    } catch (error, stackTrace) {
      _database!.execute('ROLLBACK;');
      logger.e("Failed to insert multiple games into the database.", error: error, stackTrace: stackTrace);
    } finally {
      stmt.dispose();
    }
  }


  /// Retrieves all games from the database.
  ///
  /// Returns a list of [Game] objects.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<List<Game>> getGames() async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT fetch games!");
      throw DatabaseNotInitializedException();
    }

    try {
      final ResultSet result = _database!.select('SELECT * FROM games;');
      final List<Game> games = [];
      for (var row in result) {
        games.add(Game.fromDB(
            appTitle: row['appTitle'],
            uri: row['uri'],
            isMac: row['isMac'],
            isUnix: row['isUnix'],
            isWin: row['isWin'],
            version: row['version'],
            vndbPropertiesString: row['vndbProperties'],
            userGameSettingsString: row['userGameSettings']));
      }

      logger.i("Retrieved ${games.length} games from the database.");
      return games;
    }
    catch (error, stackTrace) {
      logger.e("Failed to fetch games from the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [game] in the database.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<void> updateGame(Game game) async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT update game!");
      throw DatabaseNotInitializedException();
    }
    final gameMap = game.toMap();
    final stmt = _database!.prepare('''
      UPDATE games
      SET appTitle = ?, isMac = ?, isUnix = ?, isWin = ?, version = ?, vndbProperties = ?, userGameSettings = ?
      WHERE uri = ?;
    ''');

    _logSizeOfString(gameMap['vndbProperties']);

    try {
      stmt.execute([
        gameMap['appTitle'],
        gameMap['isMac'],
        gameMap['isUnix'],
        gameMap['isWin'],
        gameMap['version'],
        gameMap['vndbProperties'],
        gameMap['userGameSettings'],
        gameMap['uri'],
      ]);

      logger.i("Game '${game.displayName}' was successfully updated in the database.");
    }
    catch (error, stackTrace) {
      logger.w('Failed to update game "${game.displayName}" in the database.', error: error, stackTrace: stackTrace);
      rethrow;
    }
    finally {
      stmt.dispose();
    }
  }


  /// Deletes the game with the specified [uri] from the database.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<void> deleteGame(String uri) async {
    if (_isInitialized == false) {
      logger.e("Database is not initialized! Can NOT delete game!");
      throw DatabaseNotInitializedException();
    }
    final stmt = _database!.prepare('''
      DELETE FROM games
      WHERE uri = ?;
    ''');

    try {
      stmt.execute([uri]);
      logger.i('Game with URI "$uri" deleted successfully.');
    }
    catch (error, stackTrace) {
      logger.w('Failed to delete game with URI "$uri".', error: error, stackTrace: stackTrace);
      rethrow;
    }
    finally {
      stmt.dispose();
    }
  }

  ///
  /// Database Management
  ///

  /// Closes the database connection.
  ///
  /// Logs the action and ensures the database is properly disposed.
  Future<void> close() async {
    try {
      if (_isInitialized && _database != null) {
        _database!.dispose();   // Dispose the database
        _database = null;       // Remove the reference
        _isInitialized = false; // Set flag to false
        logger.t("Database connection closed.");
      }
    }
    catch (error, stackTrace) {
      logger.e("Failed to close the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }


  /// Wipes the entire database by deleting the database file and re-initializing.
  ///
  /// Throws [DatabaseNotInitializedException] if the database is not initialized.
  Future<void> wipeDatabase() async {
    try {
      // Dispose the database
      await close();

      print("123");

      // Delete the database file
      final dbFile = File(await getDatabasePath());
      if (dbFile.existsSync()) {
        try {
          dbFile.deleteSync();
          logger.i("Database file deleted successfully.");
        } catch (e) {
          logger.e("Failed to delete database file: $e");
          rethrow;
        }
      } else {
        logger.w("Database file does not exist.");
      }

      // Reset initialization state and completer
      _initCompleter = Completer<void>();

      // Re-initialize the database
      await initialize();
    }
    catch (error, stackTrace) {
      logger.e("Failed to wipe the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  ///
  /// Internal Helpers
  ///

  /// Logs the size of the provided [text].
  void _logSizeOfString(String? text) {
    final nonNullText = text ?? ""; // allow for null values to be inputted
    List<int> bytes = utf8.encode(nonNullText);
    int byteSize = bytes.length;
    logger.t("The String has A Size Of $byteSize Bytes");
  }
}
