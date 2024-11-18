// ======================================================================
// File: game_list_with_search.dart
// Description: Displays a searchable list of games with filtering
//              capabilities.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/pages/library_page/widgets/game_list_view.dart';
import 'package:boabox/services/logger_service/logger_service.dart';


/// A stateful widget that displays a searchable list of games.
///
/// The [SearchableGameList] widget provides a search bar to filter through a list of [Game] objects.
/// It leverages the [GameList] widget to display the filtered results.
class SearchableGameList extends StatefulWidget {
  /// The complete list of games to display and search through.
  final List<Game> games;

  /// The currently selected game, if any.
  final Game? selectedGame;

  /// Callback invoked when a game is selected from the list.
  final ValueChanged<Game> onGameSelected;

  /// Creates a [SearchableGameList].
  ///
  /// The [games] and [onGameSelected] parameters are required.
  const SearchableGameList({
    super.key, 
    required this.games,
    this.selectedGame,
    required this.onGameSelected,
  });

  @override
  SearchableGameListState createState() => SearchableGameListState();
}

class SearchableGameListState extends State<SearchableGameList> {
  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  /// The list of games filtered based on the search query.
  List<Game> _filteredGames = [];


  @override
  void initState() {
    super.initState();
    _filteredGames = widget.games;
    _searchController.addListener(_onSearchChanged);
    final length = widget.games.length;
    logger.t( "Initialized with $length ${length == 1? "game" : "games"}");
  }


  @override
  void didUpdateWidget(covariant SearchableGameList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games != widget.games) {
      // this will only work if the list has been replaced
      _filteredGames = widget.games;
      _onSearchChanged();
      final length = widget.games.length;
      logger.t("Game list updated with $length ${length == 1? "game" : "games"}");
    }
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }


  /// Called whenever the search query changes.
  void _onSearchChanged() {
    logger.t('Search Text: "${_searchController.text}"');
    setState(() {
      _filteredGames = widget.games
        .where((game) => (game.vndbProperties?.gameTitle ?? game.appTitle)
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()))
        .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search games',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: GamesListView(
            games: _filteredGames,
            selectedGame: widget.selectedGame,
            onGameSelected: widget.onGameSelected,
          ),
        ),
      ],
    );
  }
}
