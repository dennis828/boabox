// ======================================================================
// File: game.dart
// Description: This file contains the logic for the user game settings.
// Author: dennis828
// Date: 2024-11-16
// ======================================================================

import 'dart:convert';
import 'package:boabox/models/image64.dart';

/// A data model for user game settings.
class UserGameSettings {
  /// The Title of the game given by the user.
  String? _gameTitle;

  /// The URI of the root folder of the game selected by the user.
  String? _appUri;

  /// The cover image selected by the user.
  Image64? _coverImage;
  
  /// The banner image selected by the user.
  Image64? _bannerImage;
  
  /// The timestamp of when the last change to the properties happend.
  /// In milliseconds since epoch (UNIX Timestamp)
  late int _lastUpdated;

  /// Creates a [UserGameSettings] instance with the given properties.
  ///
  /// All parameters are optional.
  UserGameSettings({
    String? gameTitle,    // optional
    String? appUri,       // optional
    Image64? coverImage,  // optional
    Image64? bannerImage, // optional
  }) {
    _gameTitle = gameTitle;
    _appUri = appUri;
    _coverImage = coverImage;
    _bannerImage = bannerImage;
    _lastUpdated = DateTime.now().millisecondsSinceEpoch; // auto insert a timestamp
  }


  /// Creates a [UserGameSettings] instance with the given properties.
  ///
  /// All parameters are optional, but the timestamp has to specifed.
  UserGameSettings._internal(
    {String? gameTitle,     // optional
    String? appUri,         // optional
    Image64? coverImage,    // optional
    Image64? bannerImage,   // optional
    required int lastUpdated}
  ) : _gameTitle = gameTitle,
      _appUri = appUri,
      _coverImage = coverImage,
      _bannerImage = bannerImage,
      _lastUpdated = lastUpdated;


  /// Creates a [UserGameSettings] instance from a map.
  ///
  /// Useful for creating the object from data by a database.
  factory UserGameSettings.fromJsonString(String jsonString) {
    final data = json.decode(jsonString);
    return UserGameSettings._internal(
      gameTitle: data["gameTitle"],
      appUri: data["appUri"],
      coverImage: data["coverImage"] == null
        ? null
        : Image64.fromJsonString(data["coverImage"]),
      bannerImage: data["bannerImage"] == null
        ? null
        : Image64.fromJsonString(data["bannerImage"]),
      lastUpdated: data["lastUpdated"]);
  }


  /// Returns the title of the game.
  /// When updating the property the timestamp will be updated.
  String? get gameTitle => _gameTitle;
  set gameTitle(String? title) {
    _gameTitle = title;
    _lastUpdated =  DateTime.now().millisecondsSinceEpoch; // auto insert a timestamp
  }

  /// Returns the URI of the root folder.
  /// When updating the property the timestamp will be updated.
  String? get appUri => _appUri;
  set appUri(String? uri) {
    _appUri = uri;
    _lastUpdated = DateTime.now().millisecondsSinceEpoch; // auto insert a timestamp
  }

  /// Returns the cover image.
  /// When updating the property the timestamp will be updated.
  Image64? get coverImage => _coverImage;
  set coverImage(Image64? image) {
    _coverImage = image;
    _lastUpdated =
        DateTime.now().millisecondsSinceEpoch; // auto insert a timestamp
  }

  /// Returns the banner image.
  /// When updating the property the timestamp will be updated.
  Image64? get bannerImage => _bannerImage;
  set bannerImage(Image64? image) {
    _bannerImage = image;
    _lastUpdated =
        DateTime.now().millisecondsSinceEpoch; // auto insert a timestamp
  }

  /// Returns the timestamp of when the settings got updated the last time.
  /// 
  /// The format is milliseconds since epoch (UNIX Timestamp).
  int get lastUpdated => _lastUpdated;
  

  /// Converts the [UserGameSettings] instance to a JOSN string suitable for database storage.
  String toJsonString() {
    final data = {
      "gameTitle": _gameTitle,
      "coverImage": _coverImage?.toJsonString(),
      "bannerImage": _bannerImage?.toJsonString(),
      "lastUpdated": _lastUpdated,
    };

    return json.encode(data);
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // if both point to the same object in memory

    return other is UserGameSettings &&
        other.gameTitle == gameTitle &&
        other.appUri == appUri &&
        other.coverImage == coverImage &&
        other.bannerImage == bannerImage &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(
    gameTitle,
    appUri,
    coverImage,
    bannerImage,
    lastUpdated,
  );
}
