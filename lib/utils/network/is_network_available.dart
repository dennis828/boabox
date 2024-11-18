// ======================================================================
// File: is_network_available.dart
// Description: Provides a function to check network availability by
//              resolving a `github.com`.
// Author: dennis828
// Date: 2024-11-18
// ======================================================================


import 'dart:io';

import 'package:boabox/services/logger_service/logger_service.dart';

/// Checks the availability of the network by attempting to resolve a known hostname.
///
/// The [isNetworkAvailable] function attempts to perform a DNS lookup for 'github.com'.
/// If the lookup is successful and returns at least one valid IP address, it infers
/// that the device is connected to the internet.
///
/// Returns `true` if the network is available, otherwise returns `false`.
Future<bool> isNetworkAvailable() async {
  logger.i('Checking network availability by looking up github.com');
  try {
    // Attempt to lookup the IP addresses associated with 'github.com'.
    final result = await InternetAddress.lookup('github.com');
    logger.t('DNS lookup result for github.com: $result');

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      logger.i('Network is available.');
      return true;
    }
    else {
      logger.w('DNS lookup did not return any addresses.');
      return false;
    }
  }
  on SocketException catch (error) {
    // Not connected to the internet.
    logger.w('Network is unavailable. SocketException: $error');
    return false;
  }
  catch (error, stackTrace) {
    // An unexpected error occurred.
    logger.e('An unexpected error occurred while checking network availability.', error: error, stackTrace: stackTrace);
    return false;
  }
}