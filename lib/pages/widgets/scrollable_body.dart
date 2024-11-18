// ======================================================================
// File: scrollable_body.dart
// Description: A scrollable container that allows its child to be
//              scrolled when necessary. The container sizes itself based
//              on its content and allows vertical centering.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================

import 'package:flutter/material.dart';

/// A scrollable container that allows its child to be scrolled when necessary.
/// 
/// The [ScrollableBody] widget wraps its [child] with a [SingleChildScrollView] and a [Scrollbar].
/// It manages its own [ScrollController] to enable scrolling functionality.
/// 
/// **Usage Example:**
/// 
/// ```dart
/// ScrollableBody(
///   child: Column(
///     children: [
///       // Your widgets here
///     ],
///   ),
/// )
/// ```
/// 
/// **Parameters:**
/// - [child]: The widget below this widget in the tree.
/// 
/// **Behavior:**
/// - Displays a scrollbar that is always visible.
/// - Allows vertical scrolling if the content exceeds the available space.
/// - Centers the content vertically when there's sufficient space.
class ScrollableBody extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Creates a [ScrollableBody].
  ///
  /// The [child] parameter must not be null.
  const ScrollableBody({required this.child, super.key});

  @override
  State<ScrollableBody> createState() => ScrollableBodyState();
}

class ScrollableBodyState extends State<ScrollableBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize the ScrollController
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Dispose of the ScrollController to free up resources
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}
