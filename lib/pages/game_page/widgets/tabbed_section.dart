// ======================================================================
// File: tabgame_section.dart
// Description: A Flutter widget displaying different sections
//              (Overview, Characters, Game Settings) of a game using
//              tabs.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/pages/game_page/widgets/tab_characters.dart';
import 'package:boabox/pages/game_page/widgets/tab_game_settings.dart';
import 'package:boabox/pages/game_page/widgets/tab_overview.dart';


/// A widget that displays information on the game using tabs.
///
/// The [GameTabSection] widget provides a tabbed interface with three tabs:
/// - Overview
/// - Characters
/// - Game Settings
///
/// Each tab displays relevant information or settings related to the [Game] instance provided.
class GameTabSection extends StatelessWidget {
  /// The [Game] instance containing information to be displayed in the tabs.
  final Game game;

  /// The number of tabs in the [DefaultTabController].
  static const int _tabCount = 3;

  /// The labels for each tab.
  static const List<Tab> _tabs = [
    Tab(text: 'Overview'),
    Tab(text: 'Characters'),
    Tab(text: 'Game Settings'),
  ];

  /// Creates a [GameTabSection] widget.
  ///
  /// The [game] parameter must not be null.
  const GameTabSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabCount,
      child: Column(
        children: [
          const TabBar(tabs: _tabs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 16),
              child: TabBarView(
                children: [
                  OverviewTab(description: game.vndbProperties?.description),
                  CharactersTab(game: game),
                  GameSettingsTab(game: game),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
