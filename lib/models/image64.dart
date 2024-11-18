// ======================================================================
// File: image64.dart
// Description: This file contains the data model for storing in and
//              converting images to or from base64 and the exceptions
//              when dealing with them.
// Author: dennis828
// Date: 2024-11-08
// ======================================================================

import 'dart:convert';                   // For base64 encoding/decoding
import 'dart:typed_data';                // For Uint8List
import 'dart:io';                        // For File operations
import 'package:http/http.dart' as http; // for http requests
import 'package:flutter/material.dart';

import 'package:boabox/services/logger_service/logger_service.dart';



/// A container class for storing and converting images from or to base64.
class Image64 {
  /// The URL from which the image was loaded, if applicable.
  final String? url;

  /// The file path from which the image was loaded, if applicable.
  final String? filepath;

  /// The base64-encoded data of the image.
  final String base64Data;

  // Private named constructor.
  Image64._({
    this.url,
    this.filepath,
    required this.base64Data,
  });

  /// Creates an [Image64] instance from raw bytes.
  ///
  /// Optionally accepts a [url] and [filepath] to indicate the source of the image.
  factory Image64.fromBytes({
    String? url,
    String? filepath,
    required Uint8List bytes,
  }) {
    final base64Data = base64.encode(bytes);
    return Image64._(
      url: url,
      filepath: filepath,
      base64Data: base64Data,
    );
  }


  /// Creates an [Image64] instance by parsing a JSON string.
  ///
  /// The [jsonString] must contain the keys `base64Data`, `url`, and `filepath`.
  factory Image64.fromJsonString(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return Image64._(
      base64Data: data['base64Data'] as String,
      url: data['url'] as String?,
      filepath: data['filepath'] as String?,
    );
  }


  /// Creates an [Image64] instance by downloading the image from the specified [url].
  ///
  /// Throws an [ImageLoadException] if the image cannot be loaded.
  static Future<Image64> fromUrl(String url) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (error, stackTrace) {
      logger.w(
        'Error loading image from URL: $url',
        error: error,
        stackTrace: stackTrace,
      );
      throw ImageLoadException('Error loading image from URL: $url. Error: $error');
    }

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return Image64.fromBytes(url: url, bytes: bytes);
    } else {
      logger.w('Failed to load image from URL: $url. Status Code: ${response.statusCode}');
      throw ImageLoadException('Failed to load image from URL: $url. Status Code: ${response.statusCode}');
    }
  }


  /// Creates an [Image64] instance by reading the image from the specified [filepath].
  ///
  /// Throws an [ImageLoadException] if the file does not exist or cannot be read.
  static Future<Image64> fromFile(String filepath) async {
    final file = File(filepath);
    if (!await file.exists()) {
      logger.w('Error loading image. File not found: $filepath');
      throw ImageLoadException('Error loading image. File not found: $filepath');
    }

    try {
      final bytes = await file.readAsBytes();
      return Image64.fromBytes(filepath: filepath, bytes: bytes);
    } catch (error, stackTrace) {
      logger.w(
        'Error loading image from file: $filepath',
        error: error,
        stackTrace: stackTrace,
      );
      throw ImageLoadException(
          'Error loading image from file: $filepath. Error: $error');
    }
  }


  /// Not implemented.
  ///
  /// Intended to create an [Image64] instance from an executable image (Windows).
  /// 
  /// Throws an [UnimplementedError].
  static Future<Image64> fromExecutable(String execPath) async {
    throw UnimplementedError('fromExecutable is not implemented yet.');
  }


  /// Returns the raw bytes of the image.
  ///
  /// If the base64 data contains a comma (`,`), it splits and decodes the part after the comma.
  Uint8List get bytes {
    var data = base64Data;
    if (data.contains(',')) {
      data = data.split(',').last;
    }
    return base64.decode(data);
  }


  /// Returns a Flutter [Image] widget constructed from the base64 data.
  ///
  /// Optionally accepts a [fit] parameter to specify how the image should be inscribed into the space allocated during layout.
  Image getImageWidget({BoxFit? fit}) {
    return Image.memory(
      decodeBase64(),
      fit: fit,
    );
  }


  /// Decodes the base64 data to raw bytes.
  ///
  /// Throws an [InvalidImageFormatException] if decoding fails.
  Uint8List decodeBase64() {
    try {
      return base64Decode(base64Data);
    } catch (error, stackTrace) {
      logger.w('Failed to decode base64 data.', error: error, stackTrace: stackTrace);
      throw InvalidImageFormatException('Failed to decode base64 data: $error');
    }
  }


  /// Converts the [Image64] instance to a JSON string.
  ///
  /// The resulting JSON includes `base64Data`, `url`, and `filepath`.
  String toJsonString() {
    final data = {
      'url': url,
      'filepath': filepath,
      'base64Data': base64Data,
    };
    return json.encode(data);
  }



  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // if both point to the same object in memory

    return other is Image64 &&
        other.url == url &&
        other.filepath == filepath &&
        other.base64Data == base64Data;
  }

  @override
  int get hashCode => base64Data.hashCode;
}





//
// Exeptions
//

/// Exception thrown when an image fails to load from a URL or file path.
class ImageLoadException implements Exception {
  /// The error message describing the failure.
  final String message;

  /// Creates an [ImageLoadException] with the given [message].
  ImageLoadException(this.message);

  @override
  String toString() => 'ImageLoadException: $message';
}


/// Exception thrown when the image format is invalid or unsupported.
class InvalidImageFormatException implements Exception {
  /// The error message describing the invalid format.
  final String message;

  /// Creates an [InvalidImageFormatException] with the given [message].
  InvalidImageFormatException(this.message);

  @override
  String toString() => 'InvalidImageFormatException: $message';
}
