// ======================================================================
// File: game_repository.dart
// Description: Defines the abstract repository for managing game data,
//              including fetching, adding, updating, and deleting games.
//
// Author: dennis828
// Date: 2024-11-18
// ======================================================================

import 'package:boabox/models/game.dart';

/// An abstract repository that defines methods for managing game data.
///
/// The [GameRepository] interface provides methods to fetch, add, update,
/// and delete games from the data source.
abstract class GameRepository {
  /// Fetches the list of all games.
  ///
  /// Returns a [Future] that completes with a list of [Game] objects.
  Future<List<Game>> fetchGames();

  /// Adds a new [game] to the repository.
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> addGame(Game game);

  /// Updates an existing [game] in the repository.
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> updateGame(Game game);

  /// Deletes the game identified by [uri] from the repository.
  ///
  /// Returns a [Future] that completes when the operation is done.
  Future<void> deleteGame(String uri);
}
