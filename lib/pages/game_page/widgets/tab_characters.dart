// ======================================================================
// File: characters_tab.dart
// Description: A Flutter widget displaying a grid of character images
//              with hover effects.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/services/vndb_api_service/vndb_api.dart';
import 'package:boabox/services/logger_service/logger_service.dart';


/// A tab that displays characters associated with a specific game.
class CharactersTab extends StatelessWidget {
  /// The [Game] instance for which characters are to be displayed.
  final Game game;

  /// Creates a [CharactersTab] widget.
  ///
  /// The [game] parameter must not be null.
  const CharactersTab({
    super.key,
    required this.game
  });

  /// Fetches the list of characters associated with the game's vndb ID.
  ///
  /// Returns an empty list if the vndb ID is not available for this game.
  Future<List<Map<String, String>>> _fetchCharacters() async { // TODO: create character model
    final vndbId = game.vndbProperties?.vndbId;
    if (vndbId == null) {
      logger.w('CharactersTab: vndb ID is null for game "${game.appTitle}".');
      return [];
    }

    try {
      final data = await VndbApi.getCharactersByVnId(vnid: vndbId);
      return data;
    }
    catch (error, stackTrace) {
      logger.e(
        'CharactersTab: Failed to fetch characters for vndb ID $vndbId.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _fetchCharacters(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.error
            ),
          );
        } else if (snapshot.hasData) {
          final characters = snapshot.data!;
          if (characters.isEmpty) {
            return Center(
              child: Text(
                "No Data Available",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ImageGrid(items: characters);
        }
        return Center(
          child: Text(
            "No Data Available",
            style: Theme.of(context).textTheme.displayMedium,
          ),
        );
      },
    );
  }
}

/// A grid view displaying character images.
class ImageGrid extends StatelessWidget {
  /// The list of [Character] instances to display.
  final List<Map<String, String>> items;


  /// Creates an [ImageGrid] widget.
  ///
  /// The [characters] parameter must not be null.
  const ImageGrid({
    super.key,
    required this.items,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,          // Number of columns
          crossAxisSpacing: 10,       // Horizontal spacing between items
          mainAxisSpacing: 10,        // Vertical spacing between items
          childAspectRatio: 0.85 / 1, // Width : Height ratio
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return HoverImageItem(
            fname: item['fname']!,
            lname: item['lname']!,
            uri: item['uri']!,
          );
        },
      ),
    );
  }
}



/// A widget that displays a character's image with hover effects.
class HoverImageItem extends StatefulWidget {
  /// The characters first name.
  final String fname;

  /// The characters last name.
  final String lname;

  /// The vndb URI of the character.
  final String uri;

  /// Creates a [HoverImageItem] widget.
  ///
  /// The parameters related to the character must not be null.
  const HoverImageItem({
    super.key,
    required this.fname,
    required this.lname,
    required this.uri,
  });

  @override
  HoverImageItemState createState() => HoverImageItemState();
}

class HoverImageItemState extends State<HoverImageItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion( // Detect when the mouse enters the widget.
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) { // Detect when the mouse exits the widget
        setState(() {
          _isHovered = false;
        });
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 0.85 / 1, // Width : Height ratio
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.uri,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(context).colorScheme.error,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Display overlay with text when hovered.
          if (_isHovered)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45, // Semi-transparent overlay
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.lname == ""
                      ? widget.fname
                      : "${widget.fname}\n${widget.lname}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 0.9,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
