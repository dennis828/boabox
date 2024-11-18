// ======================================================================
// File: logger_service.dart
// Description: Provides a unified logger service that configures and 
//              returns a logger instance based on the build environment.
// Author: Your Name
// Date: 2024-11-18
// ======================================================================

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'logger_development.dart';
import 'logger_production.dart';

///
/// Available Logger Methods
///
/// - `logger.v("Verbose message");`  // Verbose
/// - `logger.d("Debug message");`    // Debug
/// - `logger.i("Info message");`     // Info
/// - `logger.w("Warning message");`  // Warning
/// - `logger.e("Error message");`    // Error
/// - `logger.wtf("WTF message");`    // What a Terrible Failure
///

/// Retrieves the appropriate [Logger] instance based on the build mode.
///
/// - Returns a production logger when in release mode.
/// - Returns a development logger otherwise.
///
/// This function ensures that logging behavior is consistent with the 
/// application's environment, providing detailed logs during development
/// and concise logs in production.
Logger getLogger() {
  if (kReleaseMode) {
    return getProductionLogger();
  }
  return getDevelopmentLogger();
}

/// A globally accessible logger instance configured according to the build mode.
///
/// Utilize this [logger] throughout the application to log messages at various
/// severity levels. The underlying logger configuration (development or 
/// production) is determined at runtime based on the build environment.
final logger = getLogger();
