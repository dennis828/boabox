// ======================================================================
// File: settings_divider.dart
// Description: Displays a horizontal divider with a centered label.
// Author: Your Name
// Date: 2024-11-17
// ======================================================================

import 'package:flutter/material.dart';

/// A stateless widget that displays a horizontal divider with a centered label.
///
/// The [LabeledDivider] widget creates a visual separation in the UI with
/// a text label centered between two divider lines. This is commonly used
/// in settings pages or forms to group related sections.
class LabeledDivider extends StatelessWidget {
  /// The text label to display between the dividers.
  final String label;

  /// The thickness of the divider lines.
  final double thickness;

  /// The color of the divider lines.
  final Color? dividerColor;

  /// The text style of the label.
  final TextStyle? labelStyle;

  /// Creates a [LabeledDivider].
  ///
  /// The [label] parameter is required and specifies the text to display.
  /// Optional parameters [thickness], [dividerColor], and [labelStyle] allow
  /// further customization of the divider and label appearance.
  const LabeledDivider({
    super.key,
    required this.label,
    this.thickness = 1.0,
    this.dividerColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Define the divider with customizable thickness and color.
    final Divider horizontalDivider = Divider(
      thickness: thickness,
      color: dividerColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: horizontalDivider),
          const SizedBox(width: 8.0), // spacing inbetween
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8.0), // spacing inbetween
          Expanded(child: horizontalDivider),
        ],
      ),
    );
  }
}
