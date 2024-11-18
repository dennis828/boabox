// ======================================================================
// File: settings_repository.dart
// Description: Defines the abstract repository for managing the 
//              application settings.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'package:boabox/models/user_app_settings.dart';

/// An abstract repository that defines methods for managing the application settings.
///
/// The [SettingsRepository] interface provides methods to fetch, update,
/// and delete the application settings from the database.
abstract class SettingsRepository {
  /// Fetches the application settings.
  ///
  /// Returns a [Future] that completes with a [UserAppSettings] objects.
  Future<UserAppSettings> fetchSettings();

  /// Updates the new [UserAppSettings] to the database.
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> upsertSettings(UserAppSettings settings);

  /// Deletes the [UserAppSettings] from the database.
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> wipeDatabase();
}
