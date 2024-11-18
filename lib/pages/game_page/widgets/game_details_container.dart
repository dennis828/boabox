// ======================================================================
// File: game_details_container.dart
// Description: A Flutter widget displaying detailed information about a game,
//              including status, developers, and tags.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/pages/widgets/scrollable_body.dart';
import 'package:boabox/pages/widgets/border_with_gap_painter.dart';


/// A container widget that displays detailed information about a game,
/// including its development status, developers, and associated tags.
class GameDetailsContainer extends StatelessWidget {
  /// The [Game] instance containing the game's details.
  final Game game;

  /// Creates a [GameDetailsContainer] widget.
  ///
  /// The [game] parameter must not be null.
  const GameDetailsContainer({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 16, 16),
        padding: const EdgeInsets.all(12),
        child: GameDetailsContainerContent(
          status: game.vndbProperties?.developmentStatus,
          developers: game.vndbProperties?.developers,
          tags: game.vndbProperties?.tags,
        ),
      ),
    );
  }
}


/// A widget that displays the content of the [GameDetailsContainer],
/// including development status, developers, and tags.
class GameDetailsContainerContent extends StatelessWidget {
  /// The development status of the game.
  late final String status;

  /// The developers of the game.
  late final String developers;

  /// The list of tags associated with the game.
  late final List<Map<String, dynamic>> tags; // TODO: Create Model for tags

  /// Creates a [GameDetailsContainerContent] widget.
  ///
  /// Converts raw data into formatted strings for display.
  GameDetailsContainerContent({
    super.key,
    required int? status,
    required List<Map<String, String>>? developers,
    required List<Map<String, dynamic>>? tags,
  }) {
    this.status = _statusIntToString(status);
    this.developers = _developerListToString(developers);
    this.tags = tags ?? [];
  }

  /// Converts the development status integer to a human-readable string.
  static String _statusIntToString(int? status) {
    switch (status) {
      case 0:
        return "Finished";

      case 1:
        return "In Development";

      case 2:
        return "Aborted";

      default:
        return "Not Available";
    }
  }

  /// Converts the list of developer maps to a single string.
  static String _developerListToString(List<Map<String, String>>? developers) {
    if (developers == null || developers.isEmpty) return "Not Available";
    if (developers.length == 1) return developers[0]["name"]!;
    String developerString = developers[0]["name"]!;
    for (var i = 1; i < developers.length; i++) {
      developerString = "$developerString, ${developers[i]["name"]}";
    }
    return developerString;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxContainerHeight = 1000.0;

        return Container(
          constraints: const BoxConstraints(
            maxHeight: maxContainerHeight,
            minHeight: 0, // min height does not really matter
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjusts height based on children
            children: [
              InfoContainer(
                titleText: "Status",
                height: 40,
                child: Center(
                  child: Text(status,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              InfoContainer(
                titleText: "Developer",
                height: 40,
                child: Center(
                  child: Text(developers,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Use Flexible with FlexFit.loose to allow the child to take only needed space
              Flexible( /// TODO: use grid here instead?
                fit: FlexFit.loose,
                child: InfoContainer(
                  titleText: 'Tags',
                  child: ScrollableBody(
                    child: EvenlySpacedWrap(
                      labels: tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag["name"]),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer,
                                    fontSize: 10),
                          ),
                        )
                        .toList(),
                      spacing: 4.0,
                      runSpacing: 4.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



/// A reusable widget that displays a titled container with customizable content.
///
/// It includes a decorative border with a gap for the title.
class InfoContainer extends StatelessWidget {
  /// The title text displayed at the top of the container.
  final String titleText;

  /// The child widget displayed within the container.
  final Widget child;

  /// The vertical offset for positioning the title.
  final double titleOffset;

  /// The border radius of the container.
  final double borderRadius;

  /// The height of the container.
  final double? height;

  /// Creates an [InfoContainer] widget.
  ///
  /// The [titleText] and [child] parameters must not be null.
  const InfoContainer({
    super.key,
    required this.titleText,
    required this.child,
    this.titleOffset = 8.0,
    this.borderRadius = 8.0,
    this.height
  });

  /// Calculates the width of the gap based on the title text
  double calculateGapWidth(BuildContext context, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 12,
            ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width + 16; // Adding padding
  }

  @override
  Widget build(BuildContext context) {
    final double gapWidth = calculateGapWidth(context, titleText);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow the title to slightly overflow if needed
        children: [
          // Custom Paint for the border with a gap
          Positioned.fill(
            child: CustomPaint(
              painter: BorderWithGapPainter(
                gapWidth: gapWidth,
                borderWidth: 1.5,
                borderColor: Theme.of(context).colorScheme.tertiary,
                borderRadius: borderRadius,
                gapAlignment: Alignment.topLeft,
                offset: titleOffset,
              ),
            ),
          ),
          Positioned(
            top: -8.0,
            left: borderRadius + titleOffset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                titleText,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          // Content with Padding to Avoid Overlapping the Title
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// TODO: rework in the future
class EvenlySpacedWrap extends StatelessWidget {
  final List<Widget> labels;
  final double spacing; // Horizontal spacing between labels
  final double runSpacing; // Vertical spacing between rows

  EvenlySpacedWrap({
    required this.labels,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        List<List<Widget>> rows = [];
        List<Widget> currentRow = [];
        double currentRowWidth = 0;

        for (var label in labels) {
          // Use a key to measure the size of the label
          final key = GlobalKey();
          Widget labelWithKey = Container(
            key: key,
            child: label,
          );

          // Add the label to the current row to measure its width
          currentRow.add(labelWithKey);

          // Temporarily build the label to measure its size
          // Note: This is a simplification. In a real scenario, you might need to use WidgetsBinding
          // or other methods to measure widget sizes accurately.
          // Here, we'll estimate using min intrinsic width.

          // Assume each label has an intrinsic width based on its content.
          // This is an approximation and may need adjustments.
          double labelWidth = _estimateWidgetWidth(label, context);

          // Check if adding this label exceeds the row's max width
          if (currentRowWidth +
                  labelWidth +
                  (currentRow.length > 1 ? spacing : 0) >
              maxWidth) {
            // Remove the label and start a new row
            currentRow.removeLast();
            if (currentRow.isNotEmpty) {
              rows.add(List.from(currentRow));
            }
            currentRow = [labelWithKey];
            currentRowWidth = labelWidth;
          } else {
            // Add the label's width to the current row's total width
            currentRowWidth +=
                labelWidth + (currentRow.length > 1 ? spacing : 0);
          }
        }

        // Add the last row
        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
        }

        // Build the UI
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows.map((rowLabels) {
            if (rowLabels.length == 1) {
              // Single label stretches to fill the row
              return Padding(
                padding: EdgeInsets.only(bottom: runSpacing),
                child: Row(
                  children: [
                    Expanded(
                      child: rowLabels.first,
                    ),
                  ],
                ),
              );
            } else {
              // Multiple labels are spaced evenly
              return Padding(
                padding: EdgeInsets.only(bottom: runSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rowLabels,
                ),
              );
            }
          }).toList(),
        );
      },
    );
  }

  /// Estimates the width of a widget based on its content.
  /// This is a simplified estimation. For more accurate measurements,
  /// consider using [TextPainter] for Text widgets or other measurement techniques.
  double _estimateWidgetWidth(Widget widget, BuildContext context) {
    if (widget is Chip) {
      // Estimate based on text length
      String text = '';
      if (widget.label is Text) {
        text = (widget.label as Text).data ?? '';
      }
      // Approximate width: base width + text length * average character width
      return 28.0 + text.length * 7.0; // Adjust multiplier as needed
    }
    // Default estimation
    return 100.0;
  }
}
