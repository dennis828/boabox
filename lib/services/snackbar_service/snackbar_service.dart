// snackbar_service.dart
import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static BuildContext? _context;

  // Used to ensures that the SnackbarService can access the correct Buildcontext
  static void setContext(BuildContext context) {
    _context = context;
  }


  static SnackBar _snackBarBaseStyle(String message, {int? duration, Color? backgroundColor, TextStyle? textStyle}) {
    return SnackBar(
      content: Text(
        message,
        style: textStyle,
        textAlign: TextAlign.center,
        ),
      duration: Duration(seconds: duration ?? 3),
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }



  ///
  /// Message Types
  ///

  /// Used to display an information
  static void showInformation(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _snackBarBaseStyle(
        message,
        backgroundColor: Theme.of(_context!).colorScheme.primaryContainer,
        textStyle: Theme.of(_context!).textTheme.bodyMedium?.copyWith(
          color: Theme.of(_context!).colorScheme.onPrimaryContainer
        )
      ),
    );
  }

  /// Used to display a success message (e.g. settings saved)
  static void showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _snackBarBaseStyle(
        message,
        backgroundColor: Theme.of(_context!).colorScheme.primaryContainer,
        textStyle: Theme.of(_context!).textTheme.bodyMedium?.copyWith(
          color: Theme.of(_context!).colorScheme.onPrimaryContainer
        )
      ),
    );
  }

  /// Used to display a warning message
  static void showWarning(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _snackBarBaseStyle(
        message,
        // backgroundColor: Theme.of(_context!).colorScheme.primaryContainer,
        // textStyle: Theme.of(_context!).textTheme.bodyMedium?.copyWith(
        //   color: Theme.of(_context!).colorScheme.onPrimaryContainer
        // )
      ),
    );
  }

  /// Used to display an error
  static void showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      _snackBarBaseStyle(
        message,
        duration: 8,
        backgroundColor: Theme.of(_context!).colorScheme.errorContainer,
        textStyle: Theme.of(_context!).textTheme.bodyMedium?.copyWith(
          color: Theme.of(_context!).colorScheme.onErrorContainer
        )
      ),
    );
  }



  ///
  /// Game Launching
  ///

  /// The message displayed when a game is launched.
  static void showGameLaunchedSuccess(String gameTitle) {
    showInformation("$gameTitle launched!");
  }

  /// The message displayed when launching a game fails.
  /// 
  ///  - `0`: Platform not supported
  ///  - `1`: File not found
  static void showGameLaunchedError(int errorType, {String? gameTitle, String? path}) {
    switch (errorType) {
      case 0:
        showError("Your current system does not support game launching!");
        break;

      case 1:
        showError('$gameTitle can not be launched in "$path"');
        break;

      default:
        showError("Failed to launch game!");
    }
    
  }



  ///
  /// Settings Dialog
  ///

  static void showSettingSavedSuccess(int type) {
    switch (type) {
      case 0:
        showSuccess("Settings saved!");
        break;

      case 1:
        showSuccess("Game settings saved!");

      default:
        showSuccess("Settings saved!");
    }
  }

  static void showSettingSavedFailed(String message) {
    showError("Did not change Settings: $message");
  }
}
