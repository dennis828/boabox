// ======================================================================
// File: tab_overview.dart
// Description: A Flutter widget displaying the description of the game
//              using Markdown.
//
// Author: Your Name
// Date: 2024-11-17
// ======================================================================

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:boabox/services/vndb_api_service/vndb_api.dart';


/// A Flutter widget that displays the description of a game using Markdown.
///
/// The [OverviewTab] widget converts raw description text into Markdown format
/// and renders it within the UI. If no description is provided, a default
/// message is displayed.
class OverviewTab extends StatelessWidget {
  /// The Markdown-formatted description of the game.
  late final String _description;


  /// Creates an [OverviewTab] widget.
  ///
  /// The [description] parameter is optional. If not provided, a default message
  /// indicating that no description is available is used.
  /// ```
  OverviewTab({super.key, String? description}) {
    _description = VndbApi.textToMarkdown(description ?? "[i]No Description Available...[/i]");
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      selectable: true,
      data: _description,
    );
  }
}
