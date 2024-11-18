// ======================================================================
// File: vndb_api.dart
// Description: Provides methods to interact with the VNDB API for fetching
//              game properties, tags, characters, and random games.
//
// Author: Your Name
// Date: 2024-11-18
// ======================================================================

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:boabox/services/game_discovery/vndb_properties.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/services/vndb_api_service/vndb_api_query.dart';

/// A service class for interacting with the VNDB API.
///
/// The [VndbApi] class provides static methods to fetch game properties,
/// tags, characters, and random games from vndb.org.
class VndbApi {
  /// The VNDB API endpoint URI.
  static final Uri _apiEndpoint = Uri.https("api.vndb.org", "/kana");


  /// Fetches game properties by the game's title.
  ///
  /// Sends a POST request to the VNDB API with the specified [gameTitle] and
  /// retrieves the game properties based on the provided [vndbFields].
  ///
  /// Returns a [Map<String, dynamic>] containing the game properties if successful,
  /// otherwise returns `null`.
  static Future<Map<String, dynamic>?> getGamePropertiesByName(
      {required String gameTitle, required List<String> vndbFields}) async {
    final query = VndbApiQuery(
        filters: ["search", "=", gameTitle], fields: vndbFields, results: 1);

    try {
      // Send the POST request
      var response = await http.post(
        _apiEndpoint.replace(path: '${_apiEndpoint.path}/vn'), // path = /kana/vn
        headers: {'Content-Type': 'application/json'},
        body: query.package(),
      );

      logger.t('API response status code: ${response.statusCode}');

      // Handle the response
      if (response.statusCode != 200) {
        logger.w('Failed to fetch game properties by name. Status code: ${response.statusCode}');
        return null;
      }

      // Convert response body to JSON
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data["results"] is List && data["results"].isNotEmpty) {
        // make sure there is a result to return if not
        return data["results"][0];
      }
      else {
        logger.w('No results found for game title: $gameTitle');
      }
    }
    catch (e, stackTrace) {
      logger.e('Error while fetching game properties by name: $gameTitle', error: e, stackTrace: stackTrace);
      return null;
    }
    return null;
  }



  /// TODO: fix this mess
  /// Fetches game properties by the game's VNDB ID.
  ///
  /// Sends a POST request to the VNDB API with the specified [vndbId] and
  /// retrieves the game properties based on the provided [vndbFields].
  ///
  /// Returns a [Map<String, dynamic>] containing the game properties if successful,
  /// otherwise returns `null`.
  static Future<Map<String, dynamic>?> getGamePropertiesById({
    required String vndbId,
    required List<String> vndbFields
  }) async {
    final query = VndbApiQuery(filters: ["id", "=", vndbId], fields: vndbFields, results: 1);

    try {
      // Send the POST request
      var response = await http.post(
        _apiEndpoint.replace(path: '${_apiEndpoint.path}/vn'), // path = /kana/vn
        headers: {'Content-Type': 'application/json'},
        body: query.package(),
      );

      logger.t('API response status code: ${response.statusCode}');

      // Handle the response
      if (response.statusCode != 200) {
        logger.w('Failed to fetch game properties by ID. Status code: ${response.statusCode}');
        return null;
      }

      // Convert response body to json
      final data = json.decode(response.body) as Map<String, dynamic>; 

      if (data["results"] is List && data["results"].isNotEmpty) {
        logger.i('Game properties retrieved successfully for VNDB ID: "$vndbId"');
        return data["results"][0];
      } else {
        logger.w('No results found for VNDB ID: "$vndbId"');
      }
    }
    catch (error, stackTrace) {
      logger.e('Error while fetching game properties by ID: "$vndbId"', error: error, stackTrace: stackTrace);
      return null;
    }
    return null;
  }


  /// Fetches the name of a tag by its ID.
  ///
  /// Sends a POST request to the VNDB API with the specified [tagId] and
  /// retrieves the tag name.
  ///
  /// Returns the tag name as a [String] if successful, otherwise returns `null`.
  static Future<String?> getTagNameById({required String tagId}) async {
    final query = VndbApiQuery(filters: ["id", "=", tagId], fields: ["name"], results: 1);

    try {
      // Send the POST request
      var response = await http.post(
        _apiEndpoint.replace(path: '${_apiEndpoint.path}/tag'), // path = /kana/vn
        headers: {'Content-Type': 'application/json'},
        body: query.package(),
      );

      logger.t('API response status code: ${response.statusCode}');

      // Handle the response
      if (response.statusCode != 200) {
        logger.w('Failed to fetch tag name by ID. Status code: ${response.statusCode}');
        return null;
      }

      // Convert response body to json
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data["results"] is List && data["results"].isNotEmpty) {
        logger.i('Tag name retrieved successfully for ID: $tagId');
        return data["results"][0]["name"];
      } else {
        logger.w('No results found for tag ID: $tagId');
      }
    } catch (e, stackTrace) {
      logger.e('Error while fetching tag name by ID: $tagId', error: e, stackTrace: stackTrace);
      return null;
    }
    return null;
  }


  /// Fetches a list of characters associated with a VNDB ID.
  ///
  /// Sends a POST request to the VNDB API with the specified [vnid] and
  /// retrieves the characters based on the provided parameters.
  ///
  /// Returns a list of maps containing character details if successful,
  /// otherwise returns an empty list.
  static Future<List<Map<String, String>>> getCharactersByVnId({required String vnid}) async {
    final query = VndbApiQuery(filters: ["vn", "=", ["id", "=", vnid]], fields: ["name", "image.url"], page: 1, results: 10);

    try { // TODO: restructure to do while?
      var response = await http.post(
        _apiEndpoint.replace(path: '${_apiEndpoint.path}/character'), // path = /kana/character
        headers: {'Content-Type': 'application/json'},
        body: query.package(),
      );

      if (response.statusCode != 200) {
        logger.t('vndb API: Character Request Finished With Status Code ${response.statusCode}');
        return [];
      }

      // Convert response body to json
      var data = json.decode(response.body) as Map<String, dynamic>;

      // Parse the characters from the response
      List<Map<String, String>> characters = _getCharacters(data); 

      // Make sure all characters are fetched
      while (data["more"] == true) {
        query.page++;
        response = await http.post(
          _apiEndpoint.replace(path: '${_apiEndpoint.path}/character'), // path = /kana/character
          headers: {'Content-Type': 'application/json'},
          body: query.package(),
        );

        data = json.decode(response.body) as Map<String, dynamic>;

        characters.addAll(_getCharacters(data));
      }

      logger.t("Returning ${characters.length} characters for VNDB ID: $vnid");

      return characters;
    } catch (error, stackTrace) {
      logger.e("Error while fetching characters for VNDB ID: $vnid", error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// TODO: fix this mess - name is getRandomGame but it will return vndbProperties ...
  /// Fetches a random game from VNDB.
  ///
  /// Sends a POST request to the VNDB API to retrieve the highest VNDB ID,
  /// then selects a random VNDB ID within the range and fetches its properties.
  ///
  /// Returns a [VndbProperties] instance if successful.
  ///
  /// Throws a `NoRandomGameFoundError` if no game is found or an error occurs.
  static Future<VndbProperties> getRandomGame() async {
    final query = VndbApiQuery(sort: "id", reverse: true, results: 1);

    try {
      // Send the POST request to get the highest VNDB ID
      var response = await http.post(
        _apiEndpoint.replace(
            path: '${_apiEndpoint.path}/vn'), // path = /kana/character
        headers: {'Content-Type': 'application/json'},
        body: query.package(),
      );

      if (response.statusCode != 200) {
        logger.t('vndb API: Request Finished With Status Code ${response.statusCode}');
        throw "NoRandomGameFoundError";
      }

      // Convert response body to json
      var data = json.decode(response.body) as Map<String, dynamic>;

      final String maxVnId = data["results"][0]["id"];
      final int maxVnIdNum = int.parse(maxVnId.replaceAll(RegExp(r'v'), ""));

      final String randomVnId = "v${Random().nextInt(maxVnIdNum)}";

      final VndbProperties? randomGameProperties = await VndbProperties.fromApi(vndbId: randomVnId);

      logger.t('Returning Random Game with Name ${randomGameProperties?.gameTitle}');
      if (randomGameProperties != null) return randomGameProperties;
    } catch (error, stackTrace) {
      logger.w("Error While Fetching Game Properties:", error: error, stackTrace: stackTrace);
      rethrow;
    }
    throw "NoRandomGameFoundError";
  }

  /// Parses the API response to extract a list of characters.
  ///
  /// Converts the [data] map into a list of character maps containing
  /// their IDs, image URLs, first names, and last names.
  ///
  /// Returns a list of [Map<String, String>] representing the characters.
  static List<Map<String, String>> _getCharacters(Map<String, dynamic> data) {
    final List<Map<String, String>> characters = [];

    logger.t("Parsing characters from API data: $data");

    if (data["results"] == null) return characters;

    for (Map<String, dynamic> character in data["results"]) {
      final List<String> name = character["name"].split(" ");
      final String fname = name.removeAt(0);
      final String lname = name.join(" ");

      characters.add({
        "id": character["id"],
        "uri": character["image"]["url"] ?? "", // add empty string in case no image is available
        "fname": fname, // get first name
        "lname": lname
      });
    }

    logger.t("Total characters parsed: ${characters.length}");
    return characters;
  }

  /// Converts VNDB text syntax to Markdown format.
  ///
  /// Transforms various BBCode-like tags used by VNDB into their Markdown
  /// equivalents for proper rendering.
  ///
  /// - Handles [raw], [code], [b], [i], [u], [s], [url], [spoiler], and [quote] tags.
  ///
  /// Returns the converted Markdown string.
  static String textToMarkdown(String input) {
    /// Handle [raw] and [code] tags first to prevent other replacements within them
    /// Replace [raw]...[/raw] with ```raw\n...\n```
    input = input.replaceAllMapped(
      RegExp(r'\[raw\](.*?)\[/raw\]', dotAll: true),
      (match) => '```\n${match.group(1)}\n```',
    );

    /// Replace [code]...[/code] with ```code\n...\n```
    input = input.replaceAllMapped(
      RegExp(r'\[code\](.*?)\[/code\]', dotAll: true),
      (match) => '```\n${match.group(1)}\n```',
    );

    /// Handle the special case: [From [url=link]ABC[/url]] -> [From ABC](link)
    input = input.replaceAllMapped(
      RegExp(r'\[From\s*\[url=(.+?)\](.+?)\[/url\]\]', dotAll: true),
      (match) => '[From ${match.group(2)}](${match.group(1)})',
    );

    /// Replace [b]...[/b] with **...**
    input = input.replaceAllMapped(
      RegExp(r'\[b\](.*?)\[/b\]', dotAll: true),
      (match) => '**${match.group(1)}**',
    );

    /// Replace [i]...[/i] with *...*
    input = input.replaceAllMapped(
      RegExp(r'\[i\](.*?)\[/i\]', dotAll: true),
      (match) => '*${match.group(1)}*',
    );

    /// Replace [u]...[/u] with <u>...</u> (Markdown doesn't support underline natively)
    input = input.replaceAllMapped(
      RegExp(r'\[u\](.*?)\[/u\]', dotAll: true),
      (match) => '<u>${match.group(1)}</u>',
    );

    /// Replace [s]...[/s] with ~~...~~
    input = input.replaceAllMapped(
      RegExp(r'\[s\](.*?)\[/s\]', dotAll: true),
      (match) => '~~${match.group(1)}~~',
    );

    /// Replace [url=link]title[/url] with [title](link)
    input = input.replaceAllMapped(
      RegExp(r'\[url=(.+?)\](.*?)\[/url\]', dotAll: true),
      (match) => '[${match.group(2)}](${match.group(1)})',
    );

    /// Replace [spoiler]...[/spoiler] with <details><summary>Spoiler</summary>...</details>
    input = input.replaceAllMapped(
      RegExp(r'\[spoiler\](.*?)\[/spoiler\]', dotAll: true),
      (match) =>
          '<details><summary>Spoiler</summary>\n${match.group(1)}\n</details>',
    );

    /// Replace [quote]...[/quote] with > ...
    /// If you want to support multi-line quotes, prepend each line with >
    input = input.replaceAllMapped(
      RegExp(r'\[quote\](.*?)\[/quote\]', dotAll: true),
      (match) {
        String quotedText = match.group(1)!;

        /// Split into lines and prepend with >
        List<String> lines = quotedText.split('\n');
        String markdownQuote = lines.map((line) => '> $line').join('\n');
        return markdownQuote;
      },
    );

    return input;
  }
}
