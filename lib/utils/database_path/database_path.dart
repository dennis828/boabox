// ======================================================================
// File: database_path.dart
// Description: Provides functions to determine and ensure the existence
//              of the SQLite database path based on the build
//              environment.
//
// Author: dennis828
// Date: 2024-11-13
// ======================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:boabox/services/logger_service/logger_service.dart';


/// Retrieves the appropriate SQLite database path based on the build mode.
///
/// - **Development**: `{project_root}/db/database.db`
/// - **Production**: `{getApplicationSupportDirectory()}/db/database.db`
///
/// Ensures that the directory structure exists before returning the path.
///
/// Returns the absolute path to the SQLite database file as a [String].
Future<String> getDatabasePath() async {
  const dbName = 'database.db';
  late final Directory directory;

  kReleaseMode
      ? directory = await getApplicationSupportDirectory()
      : directory = Directory.current; // determine the database path
  final dbPath = path.join(directory.path, "db", dbName);

  await ensureDirectoryExists(dbPath);
  logger.i('Determined SQLite Database Path: $dbPath');

  return dbPath;
}


/// Ensures that the directory for the given [inputPath] exists.
///
/// - If [inputPath] is a directory, it verifies its existence.
/// - If [inputPath] is a file, it ensures the parent directory exists.
/// - If [inputPath] does not exist, it creates the necessary directories.
///
/// Logs the steps taken to verify and create directories as needed.
///
/// - **inputPath**: The file or directory path to ensure exists.
Future<void> ensureDirectoryExists(String inputPath) async {
  try {
    final entityType = await FileSystemEntity.type(inputPath);
    logger.t('Checking entity type for path: $inputPath -> $entityType');

    if (entityType == FileSystemEntityType.directory) {
      logger.t('Path is an existing directory: $inputPath');
      // Path is an existing directory; nothing to do.
      return;
    } else if (entityType == FileSystemEntityType.file) {
      // Path is an existing file; ensure its directory exists.
      final directoryPath = path.dirname(inputPath);
      final directory = Directory(directoryPath);
      logger.t('Path is a file. Ensuring directory exists: $directoryPath');

      if (!(await directory.exists())) {
        await directory.create(recursive: true);
        logger.i('Created directory: $directoryPath');
      } else {
        logger.t('Directory already exists: $directoryPath');
      }
    } else {
      // Path does not exist.
      if (path.extension(inputPath).isNotEmpty) {
        // Path has a file extension; treat it as a file.
        final directoryPath = path.dirname(inputPath);
        final directory = Directory(directoryPath);
        logger.t('Path has a file extension. Ensuring directory exists: $directoryPath');

        if (!(await directory.exists())) {
          await directory.create(recursive: true);
          logger.i('Created directory for file: $directoryPath');
        } else {
          logger.t('Directory already exists for file: $directoryPath');
        }
      } else {
        // Path has no extension; treat it as a directory.
        final directory = Directory(inputPath);
        logger.t('Path has no extension. Ensuring directory exists: $inputPath');

        if (!(await directory.exists())) {
          await directory.create(recursive: true);
          logger.i('Created directory: $inputPath');
        } else {
          logger.t('Directory already exists: $inputPath');
        }
      }
    }
  } catch (error, stackTrace) {
    logger.e('Failed to ensure directory exists for path: $inputPath', error: error, stackTrace: stackTrace);
    rethrow;
  }
}
