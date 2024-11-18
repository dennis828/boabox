// ======================================================================
// File: home_page.dart
// Description: Displays the home page with game recommendations and
//              interactive elements.
//
// Author: Your Name
// Date: 2024-11-17
// ======================================================================


import 'dart:typed_data';
import 'package:boabox/models/user_app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/providers/settings_provider.dart';
import 'package:boabox/pages/game_page/game_page.dart';
import 'package:boabox/providers/game_provider.dart';
import 'package:boabox/services/game_discovery/vndb_properties.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/services/vndb_api_service/vndb_api.dart';
import 'package:boabox/utils/network/is_network_available.dart';
import 'package:boabox/utils/open_webbrowser/open_webbrowser.dart';


/// A stateless widget that represents the home page.
///
/// The [HomePage] displays game recommendations from the user's library and,
/// if available, internet-based recommendations. Users can refresh local
/// recommendations and interact with recommended games.
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const Expanded(flex: 2, child: LocalGameRecommendations()),
        _buildInternetRecommendations(context),
      ],
    );
  }

  /// Builds the header section of the home page.
  ///
  /// Includes the title and a refresh button to fetch new local game recommendations.
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                "Game Recommendations From Your Library",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              iconSize: 32,
              icon: const Icon(Icons.refresh_rounded),
              color: Theme.of(context).colorScheme.onPrimary,
              tooltip: "Show New Recommendations",
              onPressed: () {
                final settingsProvider =
                    context.read<SettingsProvider>();
                settingsProvider.triggerNewLocalGameRecommendations();
              },
            ),
          ),
        ],
      ),
    );
  }


  /// Builds the internet-based game recommendations section.
  ///
  /// Displays [VndbGameRecommendations] if the network is available and internet
  /// recommendations are enabled in settings.
  Widget _buildInternetRecommendations(BuildContext context) {
    return FutureBuilder<bool>(
      future: isNetworkAvailable(),
      builder: (context, snapshot) {
        final settingsProvider = context.watch<SettingsProvider>();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData &&
            snapshot.data == true &&
            settingsProvider.enableInternetRecommendations) {
          return const VndbGameRecommendations();
        }
        return const SizedBox(height: 1);
      },
    );
  }
}



/// A stateful widget that displays internet-based game recommendations when expanded.
///
/// The [VndbGameRecommendations] allows users to reveal or hide additional game recommendations.
/// It fetches two random games from the vndb API and displays them when expanded.
class VndbGameRecommendations extends StatefulWidget {
  /// Creates an [VndbGameRecommendations].
  const VndbGameRecommendations({super.key});

  @override
  VndbGameRecommendationsState createState() => VndbGameRecommendationsState();
}

class VndbGameRecommendationsState extends State<VndbGameRecommendations> {
  bool _isExpanded = false;
  late Future<VndbProperties> randomGameFuture1;
  late Future<VndbProperties> randomGameFuture2;

  @override
  void initState() {
    super.initState();
    _loadNewGames();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _loadNewGames() {
    randomGameFuture1 = VndbApi.getRandomGame();
    randomGameFuture2 = VndbApi.getRandomGame();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: mediaQuery.width,
          height: _isExpanded ? mediaQuery.height / 4 : 50.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(0.0),
          ),
          clipBehavior: Clip.hardEdge, // Clipping the overflow
          child: _isExpanded
          ? _buildExpandedContent()
          : _buildMinimizedContent(),
        ),
      ),
    );
  }

  /// Builds the minimized content of the [VndbGameRecommendations].
  ///
  /// Displays a prompt to show two random games.
  Widget _buildMinimizedContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        Text(
          'Show Me Two Random Games',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ],
    );
  }

  /// Builds the expanded content of the [VndbGameRecommendations].
  ///
  /// Displays two [RandomGameCard] widgets and a button to load new games.
  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: RandomGameCard(
                randomGameFuture: randomGameFuture1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => setState(() => _loadNewGames()),
                  label: const Text("I'm Feeling Lucky"),
                  backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: RandomGameCard(
                randomGameFuture: randomGameFuture2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// A stateless widget that displays local game recommendations.
///
/// The [LocalGameRecommendations] widget arranges multiple [LocalGameCard]
/// widgets horizontally with appropriate padding.
class LocalGameRecommendations extends StatelessWidget {
  /// Creates a [LocalGameRecommendations].
  const LocalGameRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.all(32.0),
            child: LocalGameCard(),
          ),
          LocalGameCard(isMainWidget: true),
          Padding(
            padding: EdgeInsets.all(32.0),
            child: LocalGameCard(),
          )
        ],
      ),
    );
  }
}


/// A stateful widget that displays a single game recommendation.
///
/// The [LocalGameCard] widget interacts with the [GameProvider] and
/// [SettingsProvider] to display and handle user interactions with game recommendations.
class LocalGameCard extends StatefulWidget {
  /// Indicates whether this recommendation is the main widget.
  ///
  /// When `true`, the widget adjusts its layout to be more prominent.
  final bool isMainWidget;

  /// Creates a [LocalGameCard].
  ///
  /// The [isMainWidget] parameter defaults to `false`.
  const LocalGameCard({super.key, this.isMainWidget = false});

  @override
  State<LocalGameCard> createState() => LocalGameCardState();
}

class LocalGameCardState extends State<LocalGameCard> {
  bool _isHovered = false;
  Game? _game;

  /// Retrieves the appropriate image bytes for the game.
  ///
  /// Returns an empty [Uint8List] if no image is available to trigger the error builder.
  Uint8List _getImage() {
    if (_game == null) {
      return Uint8List(0); // return dummy value to trigger the error builder
    }

    return _game!.userGameSettings.coverImage?.bytes ??
      _game!.vndbProperties?.coverImage?.bytes ??
      _game!.userGameSettings.bannerImage?.bytes ??
      _game!.vndbProperties?.bannerImage?.bytes ??
      Uint8List(0);
  }

  /// Opens the library page and selects the current game.
  void _openLibraryPage() {
    final settingsProvider = context.read<SettingsProvider>();
    final gameProvider = context.read<GameProvider>();
    settingsProvider.selectedPageIndex = 1; // open the library page, TODO: use enum in the future
    gameProvider.selectedGame = _game;
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    if (gameProvider.isLoading) {
      // Display a loading indicator while games are being loaded
      return const Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (gameProvider.games.isEmpty) {
      // Handle the case where no games are found
      return const Center(child: Text('No Games Found.'));
    }

    if (gameProvider.games.isNotEmpty &&
        settingsProvider.newLocalGameRecommendation > 0) {
      // Initialize the random game once
      _game = gameProvider.getRandomGame();
      logger.i('Game Recommendation Is "${_game?.displayName}"');
    }

    final mediaQuery = MediaQuery.of(context).size;
    return GestureDetector(
      /// TODO: Integrate Inkwell for splash effects
      onTap: () {
        switch (settingsProvider.bannerAction) {
          case BannerAction.openLibraryPage:
            _openLibraryPage();
            break;

          case BannerAction.startGame:
            _game!.launch();
            break;

          default:
            _openLibraryPage();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.height * (widget.isMainWidget ? 0.75 : 0.5),
                maxWidth: mediaQuery.width * (widget.isMainWidget ? 0.35 : 0.2),
              ),
              child: AspectRatio(
                aspectRatio: 2 / 3, // Width : Height ratio
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(_isHovered ? .4 : .2),
                        spreadRadius: _isHovered ? 7 : 5,
                        blurRadius: 20,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _getImage(),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, object, stacktrace) {
                        return CustomPaint(
                          painter: PlaceholderPainter(
                            textColor: Theme.of(context).colorScheme.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_isHovered)
              Positioned.fill(
                  child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45, // Semi-transparent overlay
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _game?.displayName ?? "",
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
      ),
    );
  }
}

/// A stateful widget that displays a random game fetched from the vndb API.
///
/// The [RandomGameCard] handles the asynchronous fetching of game data and
/// displays it with appropriate styling and interactions.
class RandomGameCard extends StatefulWidget {
  /// The future that fetches [VndbProperties] for a random game.
  final Future<VndbProperties> randomGameFuture;

  /// Creates a [RandomGameCard].
  const RandomGameCard({super.key, required this.randomGameFuture});

  @override
  State<RandomGameCard> createState() => RandomGameCardState();
}

class RandomGameCardState extends State<RandomGameCard> {
  bool _isHovered = false;

  /// Retrieves the appropriate image bytes from [VndbProperties].
  ///
  /// Returns an empty [Uint8List] if no image is available to trigger the error builder.
  Uint8List _getImage(VndbProperties properties) {
   return properties.bannerImage?.bytes ??
      properties.coverImage?.bytes ??
      Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VndbProperties>(
      future: widget.randomGameFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.e("Error while loading game from vndb API.", error: snapshot.error, stackTrace: snapshot.stackTrace);
          return const Center(child: Text('No Game Found.'));
        }

        if (snapshot.hasData) {
          final game = snapshot.data!;
          return GestureDetector(
            /// TODO: Integrate Inkwell for splash effects
            onTap: () {
              openWebBrowser("https://vndb.org/${snapshot.data!.vndbId}");
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 1, // Width : Height ratio
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(_isHovered ? .4 : .2),
                            spreadRadius: _isHovered ? 7 : 5,
                            blurRadius: 20,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _getImage(game),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, object, stacktrace) {
                            return CustomPaint(
                              painter: PlaceholderPainter(
                                textColor: Theme.of(context).colorScheme.outline,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_isHovered) Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45, // Semi-transparent overlay
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        game.gameTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          height: 0.9,
                          shadows: const [
                            Shadow(
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
            ),
          );
        }

        // Display a loading indicator while games are being fetched
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          ),
        );
      }
    );
  }
}
