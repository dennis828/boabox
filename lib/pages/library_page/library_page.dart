// ======================================================================
// File: library_page.dart
// Description: Displays the game library with a searchable list and
//              game details.
//
// Author: Your Name
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:boabox/pages/game_page/game_page.dart';
import 'package:boabox/pages/library_page/widgets/searchable_game_list.dart';
import 'package:boabox/providers/game_provider.dart';


/// A stateful widget that represents the game library page.
///
/// The [LibraryPage] displays a searchable list of games on the left and
/// detailed information about the selected game on the right.
class LibraryPage extends StatefulWidget {
  /// Creates a [LibraryPage].
  const LibraryPage({super.key});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    if (gameProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // Left Side: Searchable Game List
        Expanded(
          flex: 1,
          child: SearchableGameList(
            games: gameProvider.games,
            selectedGame: gameProvider.selectedGame,
            onGameSelected: (game) {
              gameProvider.selectedGame = game;
            },
          ),
        ),
        // Right Side: Selected Game Details
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).colorScheme.surfaceDim,
                  Theme.of(context).colorScheme.surface
                ],
                radius: 0.8,
                center: Alignment.bottomRight,
              ),
            ),
            child: gameProvider.selectedGame == null
              ? const Center(child: Text('Select a game'))
              : GamePage(game: gameProvider.selectedGame!),
          ),
        ),
      ],
    );
  }
}
