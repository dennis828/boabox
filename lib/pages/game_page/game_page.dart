// ======================================================================
// File: game_page.dart
// Description: Displays the game details page with interactive elements.
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/providers/game_provider.dart';
import 'package:boabox/services/logger_service/logger_service.dart';
import 'package:boabox/pages/game_page/widgets/game_details_container.dart';
import 'package:boabox/pages/game_page/widgets/tabbed_section.dart';


/// A stateless widget that represents the game details page.
///
/// The [GamePage] displays information about a specific [Game], including
/// its image, title, and additional details organized in tabs.
class GamePage extends StatelessWidget {
  /// The [Game] instance to display details for.
  final Game game;

  /// Creates a [GamePage] with the given [game].
  const GamePage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    logger.t('Game Details Page Build with Game "${game.displayName}"');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
            ImageContainer(),
            Positioned(
              bottom: -15,
              child: Row(
                children: [PlayButton(), GameTitleDisplay()],
              ),
            )
          ],
        ),
        const SizedBox(height: 20), // Add spacing
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GameTabSection(game: game),
              ),
              Expanded(
                flex: 1,
                child: GameDetailsContainer(game: game),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A button widget that allows the user to play the selected game.
///
/// The [PlayButton] interacts with the [GameProvider] to launch the game.
/// It listens for changes in the selected game and rebuilds accordingly.
class PlayButton extends StatelessWidget {
  /// Creates a [PlayButton].
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 20, 0),
      child: SizedBox(
        width: 120,
        child: Selector<GameProvider, Game?>(
          selector: (context, provider) => provider.selectedGame,
          shouldRebuild: (previous, next) {
            // Rebuild only if one of the game titles changed
            if (previous?.appTitle != next?.appTitle) return true;
            if (previous?.vndbProperties?.gameTitle !=
                next?.vndbProperties?.gameTitle) return true;
            if (previous?.userGameSettings.gameTitle !=
                next?.userGameSettings.gameTitle) return true;
            return false;
          },
          builder: (context, game, child) {
            if (game == null) return const SizedBox.shrink();
            return FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              onPressed: () => game.launch(),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Transform.translate(
                  offset: const Offset(0, 1),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                Text(
                  "PLAY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 22,
                    fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// A widget that displays the title of the selected game.
///
/// The [GameTitleDisplay] listens to the [GameProvider] and updates the
/// displayed title when the selected game changes.
class GameTitleDisplay extends StatelessWidget {
  /// Creates a [GameTitleDisplay].
  const GameTitleDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, Game?>(
      selector: (context, provider) => provider.selectedGame,
      shouldRebuild: (previous, next) {
        // Rebuild only if one of the game titles changed
        if (previous?.appTitle != next?.appTitle) return true;
        if (previous?.vndbProperties?.gameTitle !=
            next?.vndbProperties?.gameTitle) return true;
        if (previous?.userGameSettings.gameTitle !=
            next?.userGameSettings.gameTitle) return true;
        return false;
      },
      builder: (context, game, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),  // Fully transparent on the left
                    Colors.black.withOpacity(0.25), // Slightly less opaque in the center
                    Colors.black.withOpacity(0.0),  // Fully transparent on the right
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.5, 1.0], // Maintained transition points
                  tileMode:TileMode.clamp,      // Ensures the gradient doesn't repeat
                ),
                borderRadius: BorderRadius.circular(16.0), // Match ClipRRect
              ),
              child: Text(
                game?.displayName ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFE1E1E1),
                  fontSize: 22,
                  fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}


/// A widget that displays the game's banner image.
///
/// The [ImageContainer] listens to the [GameProvider] and displays the
/// appropriate image based on the selected game. If no image is available,
/// it shows a placeholder with repeated "NO IMAGE AVAILABLE" text.
class ImageContainer extends StatelessWidget {
  /// Creates an [ImageContainer].
  const ImageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, Game?>(
      selector: (context, provider) => provider.selectedGame,
      shouldRebuild: (previous, next) {
        // Rrebuild only if image by the user or api changed
        if (previous?.userGameSettings.bannerImage?.base64Data !=
          next?.userGameSettings.bannerImage?.base64Data) return true;

        if (previous?.vndbProperties?.bannerImage?.base64Data !=
          next?.vndbProperties?.bannerImage?.base64Data) return true;

        return false;
      },
      builder: (context, selectedGame, child) {
        final image = selectedGame?.userGameSettings.bannerImage
            ?.getImageWidget(fit: BoxFit.cover) ??
          selectedGame?.vndbProperties?.bannerImage
            ?.getImageWidget(fit: BoxFit.cover);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate height based on the desired aspect ratio
            double width = constraints.maxWidth;
            double height = width / 1.745;

            return Container(
              width: double.infinity,
              height: height,
              color:  Theme.of(context).colorScheme.surfaceDim,
              child: image != null
                ? ClipRect(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: image,
                  ),
                )
                : CustomPaint(
                  size: Size(width, height),
                  painter: PlaceholderPainter(
                    textColor: Theme.of(context).colorScheme.outline),
                ),
            );
          },
        );
      },
    );
  }
}

/// A custom painter that draws repeated "NO IMAGE AVAILABLE" text.
///
/// The [PlaceholderPainter] creates a pattern of text across the container,
/// with each row horizontally shifted based on a pseudo-random pattern.
/// This creates a subtle placeholder effect when no image is available.
class PlaceholderPainter extends CustomPainter {
  /// The text to display as a placeholder.
  static const String text = "NO IMAGE AVAILABLE";

  /// The color of the placeholder text.
  final Color? textColor;

  /// The font size of the placeholder text.
  final double? fontSize;

  /// The horizontal shift applied to each subsequent row.
  final double? rowShift;

  /// Predefined list of shift values for pseudo-random pattern.
  late final List<double> shiftValues;

  /// The text style used for painting the text.
  late final TextStyle textStyle;

  /// Maximum horizontal shift to prevent excessive shifting.
  static const double maxShift = 50.0;


  /// Creates a [PlaceholderPainter].
  ///
  /// The [rowShift] can be provided to alternate shifts between rows.
  PlaceholderPainter({this.rowShift, this.textColor, this.fontSize}) {
    shiftValues = rowShift == null
      ? List<double>.generate(
        10,
        (index) => Random().nextDouble() * 2 * maxShift - maxShift, // Shifts between -50 and +50
        )
      : [];

    textStyle = TextStyle(
      color: textColor ?? Colors.black.withOpacity(0.1),
      fontSize: fontSize ?? 20,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Clip the canvas to the size of the container to prevent drawing outside
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    // Layout the text to obtain its size
    textPainter.layout();
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Define spacing between repeated texts
    double horizontalSpacing = textWidth + 50;
    double verticalSpacing = textHeight + 20;

    // Calculate the maximum number of rows that fit without clipping at the bottom
    int numberOfRows =
        ((size.height - textHeight) / verticalSpacing).floor() + 3;

    for (int row = 0; row < numberOfRows; row++) {
      double currentXOffset;

      if (rowShift == null) {
        // Use the predefined shift pattern
        currentXOffset = shiftValues[row % shiftValues.length];
      } else {
        // Alternate between 0 and the provided rowShift
        currentXOffset = (row % 2 == 0) ? 0 : rowShift!;
      }

      // Start drawing texts in the current row
      for (double x = currentXOffset; x < size.width; x += horizontalSpacing) {
        textPainter.paint(canvas, Offset(x, row * verticalSpacing));
      }
    }
  }

  @override
  bool shouldRepaint(covariant PlaceholderPainter oldDelegate) {
    // Repaint only if the shift pattern changes
    if (rowShift != oldDelegate.rowShift) return true;
    if (rowShift == null && !_listEquals(shiftValues, oldDelegate.shiftValues)) return true;
    return false;
  }

  /// Helper method to compare two lists of doubles.
  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
