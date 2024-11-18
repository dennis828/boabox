// ======================================================================
// File: tag.dart
// Description: Model class representing a tag associated with a game.
// Author: dennis828
// Date: 2024-11-17
// ======================================================================

/// TODO

import 'dart:convert';

/// Represents a tag associated with a game.
class Tag {
  /// The name of the tag.
  final String name;

  /// Creates a [Tag] instance.
  ///
  /// The [name] parameter must not be null.
  const Tag({
    required this.name,
  });

  /// Creates a [Tag] instance from a map.
  ///
  /// Throws a [FormatException] if the map contains invalid data.
  factory Tag.fromMap(Map<String, dynamic> map) {
    if (map['name'] == null) {
      throw FormatException('Missing required field "name" for Tag.');
    }
    return Tag(
      name: map['name'] as String,
    );
  }

  /// Converts the [Tag] instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  /// Creates a [Tag] instance by parsing a JSON string.
  factory Tag.fromJsonString(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return Tag.fromMap(data);
  }

  /// Converts the [Tag] instance to a JSON string.
  String toJsonString() {
    return json.encode(toMap());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tag && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
