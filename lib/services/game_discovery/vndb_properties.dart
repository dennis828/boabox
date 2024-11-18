// ======================================================================
// File: vndb_properties.dart
// Description: This file holds the properties class for storing game
//              properties retrieved from vndb.org.
//
// Author: dennis828
// Date: 2024-11-07
// ======================================================================

/// TODO: SPLIT API OPERATIONS FROM MODEL DEFINITION

import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:boabox/models/image64.dart';
import 'package:boabox/services/game_discovery/vndb_image_link_extractor.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/services/vndb_api_service/vndb_api.dart';

/// A class for storing the properties of a game retrieved from vndb.org.
///
/// This class encapsulates various attributes of a game, including images,
/// descriptions, tags, developers, and ratings.
/// At this point **not** all properties listed here (https://api.vndb.org/kana#database-querying) are implemented.
class VndbProperties {
  /// The VNDB ID of the game.
  final String vndbId;

  /// The title of the game.
  String gameTitle;

  /// The development status of the game.
  int developmentStatus;

  /// The cover image of the game in base64 format.
  Image64? coverImage;

  /// The banner image of the game in base64 format.
  Image64? bannerImage;

  /// The description of the game.
  String? description;

  /// A list of tags associated with the game.
  ///
  /// Each tag is represented as a map containing its
  ///  * ID
  ///  * Name
  ///  * Rating.
  /// ```
  /// [
  ///   {
  ///     "id" : "g32",
  ///     "name" : "ADV",
  ///     "rating" : 2.4
  ///   },
  ///   ...
  /// ]
  /// ```
  final List<Map<String, dynamic>> tags = [];

  /// A list of developers associated with the game.
  ///
  /// Each developer is represented as a map containing its
  ///  * ID
  ///  * Name.
  /// ```
  /// [
  ///   {
  ///     "id" : "...",
  ///     "name" : "...",
  ///   },
  ///   ...
  /// ]
  /// ```
  final List<Map<String, String>> developers = [];

  /// The rating of the game on a scale from 1 to 5.
  double? rating;

  /// The timestamp of the last update.
  late int lastUpdated;


  // List<String> reviews = []; // TODO: implement


  /// Creates a new instance of [VndbProperties].
  ///
  /// Required parmeters:
  ///  * [vndbId]
  ///  * [gameTitle]
  ///  * [developmentStatus]
  /// 
  /// 
  /// Optional parameters:
  ///  * [coverImage]
  ///  * [bannerImage]
  ///  * [description],
  ///  * [tags]
  ///  * [developers]
  ///  * [rating].
  VndbProperties({
    required this.vndbId,
    required this.gameTitle,
    required this.developmentStatus,
    int? lastUpdated,
    this.coverImage,                        // optional --> those properties could be empty / have a null value
    this.bannerImage,                       // optional
    this.description,                       // optional
    List<Map<String, dynamic>>? tags,       // optional
    List<Map<String, String>>? developers,  // optional
    this.rating                             // optional
  }) {
    this.lastUpdated = lastUpdated ?? DateTime.now().millisecondsSinceEpoch;    // auto insert a timestamp
    tags != null ? this.tags.addAll(tags) : null;   // append tags if available
    developers != null ? this.developers.addAll(developers) : null; // append developers if available
    logger.t('VndbProperties instance created for VNDB ID: $vndbId');
  }


  /// Creates a [VndbProperties] instance by parsing a JSON string.
  ///
  /// This is useful for retrieving data from a database.
  factory VndbProperties.fromJsonString(String jsonString) {
    logger.t('Parsing JSON string to create VndbProperties.');

    try {
      final data = json.decode(jsonString);
      logger.t('JSON data decoded successfully.');
      return VndbProperties(
        vndbId: data["vndbId"],
        gameTitle: data["gameTitle"],
        developmentStatus: data["developmentStatus"],
        coverImage: data["coverImage"] == null ? null : Image64.fromJsonString(data["coverImage"]),
        bannerImage: data["bannerImage"] == null ? null : Image64.fromJsonString(data["bannerImage"]),
        description: data["description"],
        tags: List<Map<String, dynamic>>.from(json.decode(data["tags"])), // convert to list from json string and convert from List<dynamic> to List<Map<String, dynamic>>
        developers: jsonDecode(data["developers"]).map<Map<String, String>>((developer) { // convert to list from json string and convert from List<dynamic> to List<Map<String, String>>
          return Map<String, String>.from(developer);
        }).toList(),
        rating: data["rating"],
        lastUpdated: data["lastUpdated"]);
    }
    catch (error, stackTrace) {
      logger.e('Failed to parse JSON string.', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Converts the [VndbProperties] instance to a JSON string.
  ///
  /// This includes all properties of the instance.
  /// Logs the serialization process.
  String toJsonString() {
    final data = {
      "vndbId": vndbId,
      "gameTitle": gameTitle,
      "developmentStatus": developmentStatus,
      "coverImage": coverImage?.toJsonString(),
      "bannerImage": bannerImage?.toJsonString(),
      "description": description,
      "tags": json.encode(tags),
      "developers": json.encode(developers),
      "rating": rating
    };

    return json.encode(data);
  }

  ///
  /// Creates a [VndbProperties] instance by retrieving data from the VNDB API.
  ///
  /// Either [appTitle] or [vndbId] must be provided to identify the game.
  /// Logs each step of the API retrieval and any issues encountered.
  static Future<VndbProperties?> fromApi({String? appTitle, String? vndbId}) async {
    logger.i("Attempting to create VndbProperties using the API.");

    const List<String> fields = [
      // api fields to retrieve from the api
      "id",
      "title",
      "devstatus",
      "image.url",
      "description", // description may contain the following format: https://vndb.org/d9#4
      "tags.spoiler",
      "tags.rating",
      "tags.name",
      "developers.name",
      "rating"
    ];

    Map<String, dynamic>? apiProperties;
    try {
      if (appTitle != null) {
        apiProperties = await VndbApi.getGamePropertiesByName(
            gameTitle: appTitle, vndbFields: fields);
      } else if (vndbId != null) {
        apiProperties = await VndbApi.getGamePropertiesById(
            vndbId: vndbId, vndbFields: fields);
      } else {
        return null;
      }

      if (apiProperties == null) {
        throw "GameNotFoundError";
      }
    } catch (error, stackTrace) {
      logger.e("Error Occured While Getting VndbProperties From The Api:",
          error: error, stackTrace: stackTrace);
      return null;
    }

    Image64? coverImage; // --> try to get the "portrait cover"
    final imageUrls = await VndbImageLinkExtractor.getImageUrls(
        apiProperties["id"]); //     image using the "custom api" and
    try {
      //     match it accordingly
      if (imageUrls["portrait"] == null) {
        //
        logger.w(
            'API Did Not Provide A "Portrait" Cover Image For Game: "${apiProperties["title"]}"'); //
      } //
      else {
        //
        coverImage = await Image64.fromUrl(
            imageUrls["portrait"]!); // get the image from the url
        logger.i(
            'Using "Portrait" Image At: ${imageUrls["portrait"]}\nFor Game: "${apiProperties["title"]}"'); //
      } //
    } //
    catch (error, stackTrace) {
      // fallback: use image url provided by the api
      logger.w(
          'Trying To Usa A Fallback Image For Game: ${apiProperties["title"]}',
          error: error,
          stackTrace: stackTrace); //
      try {
        //
        coverImage = await Image64.fromUrl(apiProperties["image.url"]); //
        logger.i(
            'Using Fallback Image At: ${apiProperties["image.url"]}\nFor Game: "${apiProperties["title"]}"'); //
      } //
      catch (error, stackTrace) {
        //
        logger.w(
            'Could Not Find ANY "Portrait" Cover Image For Game: "${apiProperties["title"]}"',
            error: error,
            stackTrace: stackTrace); //
      } //
    } //

    Image64? bannerImage; // --> try to get the "landscape cover"
    try {
      //     image using the "custom api" and
      if (imageUrls["landscape"] != null) {
        //     match it accordingly
        bannerImage = await Image64.fromUrl(imageUrls["landscape"]!); //
      } //
      else {
        //
        logger.w(
            'API Did Not Provide A "Landscape" Cover Image For Game: "${apiProperties["title"]}"'); //
      } //
    } //
    catch (error, stackTrace) {
      //
      logger.w(
          'Could Not Find ANY "Landscape" Cover Image For Game: "${apiProperties["title"]}"',
          error: error,
          stackTrace: stackTrace); //
    } //

    final List<Map<String, dynamic>> tags =
        await _tagMapper(apiProperties["tags"]);
    logger.t(
        'Game "${apiProperties["title"]}" has the following tags:\n${apiProperties["tags"]}');

    final double? rating =
        apiProperties["rating"] == null ? null : apiProperties["rating"] * 0.05;
    logger.t(
        'Game "${apiProperties["title"]}" has the following rating: ${apiProperties["rating"]}');

    final List<Map<String, String>>? developers = (apiProperties["developers"]
            as List<dynamic>?)
        ?.map(//
            (item) => (item as Map<String, dynamic>).map((key, value) => MapEntry(
                key,
                value
                    .toString())) //  explicit casting of List<dynamic> to List<Map<String, String>>
            )
        .toList(); //
    logger.t(
        'Game "${apiProperties["title"]}" has the following developers: ${apiProperties["developers"]}');

    return VndbProperties(
        vndbId: apiProperties["id"],
        gameTitle: apiProperties["title"],
        developmentStatus: apiProperties["devstatus"],
        coverImage: coverImage,
        bannerImage: bannerImage,
        developers: developers ?? [],
        description: apiProperties[
            "description"], // add parser for formatting custon vndb formatting
        tags: tags,
        rating: rating);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // if both point to the same object in memory

    const equality = DeepCollectionEquality();

    return other is VndbProperties &&
        other.vndbId == vndbId &&
        other.gameTitle == gameTitle &&
        other.developmentStatus == developmentStatus &&
        other.coverImage == coverImage &&
        other.bannerImage == bannerImage &&
        other.description == description &&
        equality.equals(other.tags, tags) &&
        equality.equals(other.developers, developers) &&
        other.rating == rating; // do not last Update
  }

  @override
  int get hashCode => vndbId.hashCode ^ gameTitle.hashCode;

  /// Maps and filters tags based on spoiler and rating thresholds.
  ///
  /// Removes tags with spoilers above [spoilerThreshold] and ratings below [ratingThreshold].
  /// Logs the mapping process at trace level.
  static Future<List<Map<String, dynamic>>> _tagMapper(
      List<dynamic> inputTags) async {
    const spoilerThreshold =
        1; // threshold for removing tags with to severe spoilers
    const ratingThreshold =
        1.8; // threshold for removing tags if they are not matching the game
    final List<Map<String, dynamic>> tags = [];
    for (var tag in inputTags) {
      if (tag["spoiler"] > spoilerThreshold &&
          tag["rating"] < ratingThreshold) {
        // filter out tags
        continue;
      }
      tags.add({"name": tag["name"], "id": tag["id"], "rating": tag["rating"]});
    }
    return tags;
  }

  // ToDo: add methods to update the property
}
