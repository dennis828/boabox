// ======================================================================
// File: logger_production.dart
// Description: Configures the production logger with console and file
//              outputs.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'dart:io';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Custom [LogOutput] that writes log events to a file.
///
/// The [_FileOutput] class handles the initialization of the log file and
/// ensures that all log messages are appended with a timestamp.
class _FileOutput extends LogOutput {
  IOSink? _sink;
  final _initCompleter = Completer<void>();

  /// Initializes the file output by creating or opening the log file.
  ///
  /// The log file is located in the application's documents directory and is
  /// named `logs.txt`. This method ensures that the [IOSink] is ready before
  /// any log messages are written.
  _FileOutput() {
    _init();
  }

  /// Asynchronously initializes the log file and opens an [IOSink] for writing.
  ///
  /// Once the file is ready, the [_initCompleter] is completed to signal that
  /// logging can proceed.
  void _init() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/logs.txt');
    _sink = file.openWrite(mode: FileMode.append);
    _initCompleter.complete();
  }

  /// Handles the output of log events by writing each line to the log file.
  ///
  /// Each log message is prefixed with the current timestamp for better traceability.
  @override
  void output(OutputEvent event) async {
    await _initCompleter.future; // Ensure sink is initialized
    for (var line in event.lines) {
      _sink?.writeln('${DateTime.now()} $line');
    }
  }

  /// Closes the [IOSink] when the logger is destroyed.
  ///
  /// This ensures that all pending log messages are flushed and the file is properly closed.
  @override
  Future<void> destroy() async {
    await _sink?.close();
  }
}

/// Creates and configures a production logger.
///
/// The [getProductionLogger] function returns a [Logger] instance configured
/// for production environments. It logs messages with a severity of warning and
/// above, and outputs logs to both the console and a file.
///
/// - **level**: Sets the logging level to [Level.warning] to capture warnings, errors, and more severe messages.
/// - **printer**: Utilizes [SimplePrinter] for straightforward log formatting.
/// - **output**: Uses [MultiOutput] to enable logging to multiple destinations, including the console and a file.
Logger getProductionLogger() {
  return Logger(
    level: Level.warning,
    printer: SimplePrinter(),
    output: MultiOutput([
      ConsoleOutput(),
      _FileOutput(),
    ]),
  );
}
