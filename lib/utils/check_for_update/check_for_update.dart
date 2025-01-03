// ======================================================================
// File: check_for_update.dart
// Description: This file contains a method to check if a newer version
//              of the app is available in the GitHub repo.
//
// Author: dennis828
// Date: 2025-01-03
// ======================================================================

import 'dart:convert'; // For utf8 decoding
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> checkForUpdate() async {
  // Get the Version of the master branch from GitHub.
  final globalAppVersion = await _getGlobalAppVersion();
  
  // Get the Version of app.
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final localAppVersion = packageInfo.version;

  return globalAppVersion != localAppVersion;
}

Future<String> _getGlobalAppVersion() async {
  const mainfestPath = "https://raw.githubusercontent.com/dennis828/boabox/refs/heads/master/pubspec.yaml";
  try {
    // Fetch the YAML file from the URL
    final response = await http.get(Uri.parse(mainfestPath));

    if (response.statusCode != 200) return "";

    final yamlString = utf8.decode(response.bodyBytes);
    final yamlMap = loadYaml(yamlString);
    
    // Version is of Type 0.2.7-beta+20241124
    // Split at '+' to obtain only the version.
    return (yamlMap["version"] as String).split("+")[0];
  }
  catch (error, stackTrace) {
    logger.w("Could not check for update.", stackTrace: stackTrace, error: error);
    return "";
  }
}