// ======================================================================
// File: tag.dart
// Description: This file contains the data model for game tags and
//              their associated properteies.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


// Exception thrown when a required field is missing during construction from a map.
class MissingInput implements Exception {
  late final String message;
  MissingInput(String tagName) {
    message = 'Missing required field "$tagName" for Tag.';
  }

  @override
  String toString() => 'DatabaseNotInitializedException: $message';
}


// Defines levels of spoiler intensity for game-related tags.
enum SpoilerLevel {
  non,   // No spoilers
  light, // Mild spoilers
  heavy  // Significant spoilers
}


/// Represents a tag associated with a game.
class Tag {
  /// The name of the tag.
  final String name;

  /// The vndb id of the tag.
  final String id;

  /// The rating of the tag.
  /// This indicates how good the tag matches the given game.
  final double rating;

  /// Indicates the extent to which the tag contains game spoilers.
  final SpoilerLevel spoiler;

  /// Creates a [Tag] instance.
  ///
  /// The [name] parameter must not be null.
  const Tag({
    required this.name,
    required this.id,
    required this.rating,
    required this.spoiler
  });

  /// Creates a [Tag] instance from a map.
  ///
  /// Throws a [FormatException] if the map contains invalid data.
  factory Tag.fromMap(Map<String, dynamic> map) {
    if (map['name'] == null) {
      throw MissingInput("name");
    }

    if (map['id'] == null) {
      throw MissingInput("id");
    }

    if (map['rating'] == null) {
      throw MissingInput("rating");
    }

    if (map['spoiler'] == null) {
      throw MissingInput("spoiler");
    }

    return Tag(
      name: map['name'] as String,
      id: map['id'] as String,
      rating: map['name'] as double,
      spoiler: SpoilerLevel.values[map['spoiler'] as int]
    );
  }

  /// Converts the [Tag] instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id' : id,
      'rating' : rating,
      'spoiler' : spoiler.index
    };
  }

  // /// Creates a [Tag] instance by parsing a JSON string.
  // factory Tag.fromJsonString(String jsonString) {
  //   final data = json.decode(jsonString) as Map<String, dynamic>;
  //   return Tag.fromMap(data);
  // }

  // /// Converts the [Tag] instance to a JSON string.
  // String toJsonString() {
  //   return json.encode(toMap());
  // }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tag &&
      other.name == name &&
      other.id == id &&
      other.rating == rating &&
      other.spoiler == spoiler;
  }

  @override
  int get hashCode => id.hashCode;
}
