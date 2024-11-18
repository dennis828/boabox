// ======================================================================
// File: settings_repository_impl.dart
// Description: Implementation of the SettingsRepository interface, managing
//              CRUD operations for user application settings.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'dart:async';

import 'package:boabox/models/user_app_settings.dart';
import 'package:boabox/repositories/settings_repository.dart';
import 'package:boabox/services/database_service/database_service.dart';
import 'package:boabox/services/logger_service/logger_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  /// Indicates if the database service has been initialized
  static bool _isInitialized = false;

  /// Singleton instance
  static final SettingsRepositoryImpl _instance = SettingsRepositoryImpl._internal();

  /// Returns the singleton instance of [SettingsRepositoryImpl].
  factory SettingsRepositoryImpl() => _instance;

  /// Private constructor for singleton pattern.
  SettingsRepositoryImpl._internal();

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
  Future<UserAppSettings> fetchSettings() async {
    try {
      await _databaseService.initialize();
      return await _databaseService.getSettings() ?? UserAppSettings();
    }
    catch (error, stackTrace) {
      logger.e("Error occured while fetching settings from the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> upsertSettings(UserAppSettings settings) async {
    try {
      await _databaseService.initialize();
      await _databaseService.upsertSettings(settings);
    }
    catch (error, stackTrace) {
      logger.e("Error occured while upserting settings into the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> wipeDatabase() async {
    try {
      await _databaseService.wipeDatabase();
    }
    catch (error, stackTrace) {
      logger.e("Error occured while deleting settings from the database.", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
