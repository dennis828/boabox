// ======================================================================
// File: game_repository_impl.dart
// Description: Implements the GameRepository interface for managing
//              game data.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'dart:async';

import 'package:boabox/models/game.dart';
import 'package:boabox/repositories/game_repository.dart';
import 'package:boabox/services/database_service/database_service.dart';
import 'package:boabox/services/logger_service/logger_service.dart';

class GameRepositoryImpl implements GameRepository {
  /// Indicates if the database service has been initialized
  static bool _isInitialized = false;

  /// Singleton instance
  static final GameRepositoryImpl _instance = GameRepositoryImpl._internal(); // singleton instance
  
  /// Returns the singleton instance of [GameRepositoryImpl].
  factory GameRepositoryImpl() => _instance;

  /// Private constructor for singleton pattern.
  GameRepositoryImpl._internal();

  /// Handle for database transactions
  final _databaseService = DatabaseService();

  /// Used to avoid race conditions during initialisation
  final Completer<void> _initCompleter = Completer<void>();
  
  
  /// Initializes the [DatabaseService].
  ///
  /// Ensures that initialization is performed only once.
  Future<void> initialize() async {
    if (_isInitialized) {
      return _initCompleter.future;
    }

    await _databaseService.initialize();

    _isInitialized = true;
    _initCompleter.complete();
  }

  @override
  Future<List<Game>> fetchGames() async {
    try {
      await _databaseService.initialize();
      return await _databaseService.getGames();
    }
    catch (error, stackTrace) {
      logger.e("Error occured while fetching a game from the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> addGame(Game item) async {
    try {
      await _databaseService.initialize();
      await _databaseService.insertGame(item);
    }
    catch (error, stackTrace) {
      logger.e("Error occured while adding a game to the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateGame(Game item) async {
    try {
      await _databaseService.initialize();
      await _databaseService.updateGame(item);
    }
    catch (error, stackTrace) {
      logger.e("Error occured while updating a game in the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteGame(String uri) async {
    try {
      await _databaseService.initialize();
      await _databaseService.deleteGame(uri);
    }
    catch (error, stackTrace) {
      logger.e("Error occured while deleting a game in the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
