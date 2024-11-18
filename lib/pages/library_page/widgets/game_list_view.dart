// ======================================================================
// File: game_list.dart
// Description: Displays a scrollable list of games with selection
//              capabilities.
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/services/logger_service/logger_service.dart';

/// A stateless widget that displays a scrollable list of games.
///
/// The [GamesListView] widget presents a list of [Game] objects using a [ListView.builder].
/// It highlights the currently selected game and notifies when a game is tapped.
class GamesListView extends StatelessWidget {
  /// The list of games to display.
  final List<Game> games;

  /// The currently selected game, if any.
  final Game? selectedGame;

  /// Callback invoked when a game is tapped.
  final ValueChanged<Game> onGameSelected;

  /// Creates a [GamesListView].
  ///
  /// The [games] and [onGameTap] parameters are required.
  const GamesListView({
    super.key,
    required this.games,
    this.selectedGame,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    logger.t("GamesListView build.");
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return ListTile(
          title: Text(game.displayName),
          selected: selectedGame == game,
          onTap: () => onGameSelected(game),
        );
      },
    );
  }
}
