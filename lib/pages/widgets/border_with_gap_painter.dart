// ======================================================================
// File: border_with_gap_painter.dart
// Description: Custom painter that draws a border with a gap, suitable
//              for overlaying text or other widgets.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/material.dart';

// TODO: add missing alignments

/// A [CustomPainter] that paints a border around a container with a customizable gap.
///
/// The [BorderWithGapPainter] is designed to be used within a [Stack] widget to overlay
/// text or other widgets on top of a container that has a border with a gap.
///
/// ### Parameters:
/// - `gapWidth`: The width of the gap in the border.
/// - `borderColor`: The color of the border.
/// - `borderWidth`: The thickness of the border lines.
/// - `borderRadius`: The radius of the container's rounded corners.
/// - `gapAlignment`: The alignment of the gap within the border.
/// - `gapOffset`: The offset to adjust the position of the gap.
class BorderWithGapPainter extends CustomPainter {
  /// The width of the gap in the border.
  final double gapWidth;

  /// The thickness of the border lines.
  final double borderWidth;

  /// The color of the border.
  final Color borderColor;

  /// The radius of the container's rounded corners.
  final double borderRadius;

  /// The alignment of the gap within the border.
  final Alignment gapAlignment;

  /// The offset to adjust the position of the gap.
  final double offset;


  /// Creates a [BorderWithGapPainter].
  ///
  /// The [gapWidth], [borderColor], and [gapAlignment] parameters are required.
  BorderWithGapPainter({
    required this.gapWidth,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.gapAlignment = Alignment.topCenter, // Default alignment
    this.offset = 0
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Define the radius for rounded corners
    final radius = Radius.circular(borderRadius);

    // Calculate the position of the gap based on the alignment
    double gapStartX = 0;
    double gapStartY = 0;
    bool isHorizontal = true; // Determines if gap is on horizontal or vertical edge

    switch (gapAlignment) {
      case Alignment.topCenter:
        gapStartX = (size.width / 2) - (gapWidth / 2);
        gapStartY = 0;
        isHorizontal = true;
        break;
      case Alignment.bottomCenter:
        gapStartX = (size.width / 2) - (gapWidth / 2);
        gapStartY = size.height;
        isHorizontal = true;
        break;
      case Alignment.centerLeft:
        gapStartX = 0;
        gapStartY = (size.height / 2) - (gapWidth / 2);
        isHorizontal = false;
        break;
      case Alignment.centerRight:
        gapStartX = size.width;
        gapStartY = (size.height / 2) - (gapWidth / 2);
        isHorizontal = false;
        break;

      case Alignment.topLeft:
        gapStartX = 0;
        gapStartY = 0;
        isHorizontal = true;

      default:
        // Default to top center
        gapStartX = (size.width / 2) - (gapWidth / 2);
        gapStartY = 0;
        isHorizontal = true;
    }

    // Start drawing the border from the top-left corner
    path.moveTo(radius.x, 0);

    if (isHorizontal) {
      // Top edge up to the gap start
      path.lineTo(radius.x + gapStartX + offset, 0);

      // Skip the gap
      final gapSkip =
          radius.x + gapStartX + gapWidth + offset > size.width - radius.x
              ? size.width - radius.x
              : radius.x + gapStartX + gapWidth + offset;
      path.moveTo(gapSkip, 0);

      // Continue the top edge to top-right corner
      path.lineTo(size.width - (radius.x), 0);
    } else {
      // Left edge up to the gap start
      path.lineTo(0, gapStartY);

      // Skip the gap
      path.moveTo(0, gapStartY + gapWidth);

      // Continue the left edge to bottom-left corner
      path.lineTo(0, size.height - radius.y);
    }

    // Top-right corner
    path.arcToPoint(
      Offset(size.width, radius.y),
      radius: radius,
      clockwise: true,
    );

    if (isHorizontal) {
      // Right edge
      path.lineTo(size.width, size.height - radius.y);
    } else {
      // Right edge up to gap start
      path.lineTo(size.width, gapStartY);

      // Skip the gap
      path.moveTo(size.width, gapStartY + gapWidth);

      // Continue the right edge to bottom-right corner
      path.lineTo(size.width, size.height - radius.y);
    }

    // Bottom-right corner
    path.arcToPoint(
      Offset(size.width - radius.x, size.height),
      radius: radius,
      clockwise: true,
    );

    if (isHorizontal) {
      // Bottom edge
      path.lineTo(radius.x, size.height);
    } else {
      // Bottom edge up to gap start
      path.lineTo(size.width - radius.x, size.height);

      // Continue the bottom edge to bottom-left corner
      path.lineTo(radius.x, size.height);
    }

    // Bottom-left corner
    path.arcToPoint(
      Offset(0, size.height - radius.y),
      radius: radius,
      clockwise: true,
    );

    if (isHorizontal) {
      // Left edge
      path.lineTo(0, radius.y);
    } else {
      // Left edge up to gap start
      path.lineTo(0, size.height - radius.y);

      // Continue the left edge to top-left corner
      path.lineTo(0, radius.y);
    }

    // Top-left corner
    path.arcToPoint(
      Offset(radius.x, 0),
      radius: radius,
      clockwise: true,
    );

    // Draw the path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BorderWithGapPainter oldDelegate) {
    return oldDelegate.gapWidth != gapWidth ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gapAlignment != gapAlignment;
  }
}
