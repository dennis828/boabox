// ======================================================================
// File: logger_development.dart
// Description: Configuration of the logger that is used during
//              development:
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'package:logger/logger.dart';

/// Creates and configures a development logger.
///
/// The [getDevelopmentLogger] function returns a [Logger] instance configured
/// with settings tailored for development environments, including detailed
/// stack traces and colorful output for enhanced readability.
///
/// - **level**: Sets the logging level to [Level.trace] to capture all log messages.
/// - **printer**: Utilizes [PrettyPrinter] with customized settings.
Logger getDevelopmentLogger() {
  return Logger(
    level: Level.trace,
    printer: PrettyPrinter(
      methodCount: 4,       // Number of stacktrace methods to display
      errorMethodCount: 8,  // Number of methods when logging an error
      lineLength: 120,      // Width of the output
      colors: true,         // Colorful log messages
      printEmojis: true,    // Include emojis in logs
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Include timestamp in logs
    ),
  );
}
