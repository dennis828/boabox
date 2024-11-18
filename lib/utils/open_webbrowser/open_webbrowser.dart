// ======================================================================
// File: open_webbrowser.dart
// Description: Provides a function to open a web browser with a
//              specified URL.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'dart:io';

import 'package:boabox/services/logger_service/logger_service.dart';

/// Opens the default web browser with the specified [url].
///
/// The [openWebBrowser] function determines the operating system and executes
/// the appropriate command to launch the default web browser pointing to the given [url].
///
/// - **Windows**: Uses the `start` command.
/// - **macOS**: Uses the `open` command.
/// - **Linux**: Uses the `xdg-open` command.
///
/// Throws an [UnsupportedPlatformError] if the operating system is not supported.
///
/// Logs each step of the process, including the platform detection, command execution,
/// and any errors encountered.
///
/// Example:
/// ```dart
/// openWebBrowser('https://www.example.com');
/// ```
Future<void> openWebBrowser(String url) async {
  try {
    if (Platform.isWindows) {
      logger.t('Detected platform: Windows');
      await Process.run('start', [url], runInShell: true);
      logger.t('Web browser opened successfully on Windows.');
    } else if (Platform.isMacOS) {
      logger.t('Detected platform: macOS');
      logger.t('Executing command: open $url');
      await Process.run('open', [url]);
      logger.t('Web browser opened successfully on macOS.');
    } else if (Platform.isLinux) {
      logger.t('Detected platform: Linux');
      logger.t('Executing command: xdg-open $url');
      await Process.run('xdg-open', [url]);
      logger.t('Web browser opened successfully on Linux.');
    } else {
      logger.e('Unsupported platform: ${Platform.operatingSystem}');
      throw UnsupportedPlatformError('The current platform is not supported.');
    }
  } catch (error, stackTrace) {
    logger.e('Failed to open web browser with URL: $url', error: error, stackTrace: stackTrace);
    rethrow;
  }
}

/// Exception thrown when an unsupported platform is encountered.
class UnsupportedPlatformError extends Error {
  final String message;

  UnsupportedPlatformError(this.message);

  @override
  String toString() => 'UnsupportedPlatformError: $message';
}
