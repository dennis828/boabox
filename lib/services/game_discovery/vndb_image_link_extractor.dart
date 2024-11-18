// ======================================================================
// File: vndb_image_link_extractor.dart
// Description: Custom API for vndb.org to retrieve cover images of games
//              if available.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================

import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:http/http.dart';


/// Enumeration for image orientations.
enum ImageOrientation { portrait, landscape }


/// A service to extract cover image URLs from vndb.org for a given game ID.
///
/// The [VndbImageLinkExtractor] class provides methods to fetch and parse
/// cover images based on the game's VNDB ID.
class VndbImageLinkExtractor {
  /// URL of the target web site
  static const String _baseUrl = "https://vndb.org";

  /// Generates the link to the "covers page" based on the vndbId.
  ///
  /// Logs the generated URL at info level.
  static String _getLinkToPage(String vndbId) {
    return "$_baseUrl/$vndbId/cv#cv";
  }

  /// Parses the image links from the HTML content.
  ///
  /// Returns a map with orientations as keys and image URLs as values:
  /// ```
  ///  {
  ///    "landscape" : "...",
  ///    "portrait" : "..."
  ///  }
  /// ```
  /// empty: `{}`
  static Map<String, String> _parseImageLinks(String htmlContent) {
    // Parse the HTML content
    Document document = html_parser.parse(htmlContent);
    Map<String, String> result = {};
    Element? vncoversDiv = document.querySelector('div.vncovers'); // try to find the div with class 'vncovers'

    if (vncoversDiv == null) {
      logger.w("Could not find any covers in the webpage!");
      return result; // if 'vncovers' div is not found, return an empty map
    }

    // find all divs with class 'imghover' inside the 'vncovers' div
    List<Element> imghoverDivs = vncoversDiv.querySelectorAll('div.imghover'); 

    for (Element imghoverDiv in imghoverDivs) {
      String? style = imghoverDiv.attributes['style'];
      if (style != null) {
        // Extract width and height from the style attribute
        RegExp widthRegExp = RegExp(r'width:\s*(\d+)px');
        RegExp heightRegExp = RegExp(r'height:\s*(\d+)px');

        Match? widthMatch = widthRegExp.firstMatch(style);
        Match? heightMatch = heightRegExp.firstMatch(style);

        if (widthMatch != null && heightMatch != null) {
          int width = int.parse(widthMatch.group(1)!);
          int height = int.parse(heightMatch.group(1)!);

          // Determine orientation based on dimensions
          String orientation = height > width ? 'portrait' : 'landscape';

          // Get the href attribute from the <a> tag inside the 'imghover' div
          Element? aTag = imghoverDiv.querySelector('a');
          if (aTag != null) {
            String? href = aTag.attributes['href'];
            if (href != null) {
              result[orientation] = href;
              logger.t('Found Image With Orientation "$orientation": $href');
            }
          }
        }
      }
    }
    logger.i('Completed parsing image links. Total found: ${result.length}');
    return result;
  }


  /// Fetches the HTML content of a page given its URL.
  ///
  /// Returns the HTML as a string if successful, otherwise null.
  static Future<String?> _fetchPageContents(String url) async {
    late final Response response;
    try {
      response = await http.get(
        Uri.parse(url),
        headers: {
          // add headers to prevent blocking
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
                  ' Chrome/70.0.3538.77 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Connection': 'keep-alive',
        },
      );
      logger.t('HTTP GET request sent to "$url"');
    }
    catch (error, stackTrace) {
      logger.w('Error while fetching HTML at URL: "$url"', error: error, stackTrace: stackTrace);
      return null;
    }
    if (response.statusCode == 200) {
      logger.t('Request finished with status code 200 (Success)');
      return response.body;
    }
    logger.t('Request finished with status code 200 (Success)');
    return null;
  }

  /// Retrieves the cover image URLs for a vndb.org game ID.
  ///
  /// Returns a map with orientations as keys and image URLs as values.
  /// If no images are found, an empty map is returned.
  static Future<Map<String, String>> getImageUrls(String vndbId) async {
    final url = _getLinkToPage(vndbId);
    final html = await _fetchPageContents(url);

    if (html == null) {
      logger.w('Failed to fetch HTML content for vndb ID: "$vndbId"');
      return {};
    }

    return _parseImageLinks(html);
  }
}
