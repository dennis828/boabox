// ======================================================================
// File: game_settings_tab.dart
// Description: A Flutter widget for managing and displaying game
//              settings, including images and paths.
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:croppy/croppy.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'package:boabox/models/game.dart';
import 'package:boabox/models/image64.dart';
import 'package:boabox/providers/game_provider.dart';
import 'package:boabox/services/logger_service/logger_service.dart';


/// A Flutter widget that provides an interface for managing game settings,
/// including banner and cover images, game title, executable path, and game deletion.
class GameSettingsTab extends StatefulWidget {
  /// The [Game] instance for which settings are being managed.
  final Game game;


  /// Creates a [GameSettingsTab] widget.
  ///
  /// The [game] parameter must not be null.
  const GameSettingsTab({super.key, required this.game});

  @override
  GameSettingsTabState createState() => GameSettingsTabState();
}

class GameSettingsTabState extends State<GameSettingsTab> {
  /// Picks and crops the banner image with a predefined aspect ratio.
  Future<void> _pickBannerImage() async {
    const aspectRatio = CropAspectRatio(width: 1745, height: 1000);
    final image = await _pickImage();

    if (image == null) {
      logger.t("No banner image has been selected.");
      return;
    }
    
    final bytes = await _openCroppyDialog(imageBytes: image, aspectRatio: aspectRatio);
    if (bytes == null) {
      logger.t("User aborted in croppy dialog.");
      return;
    }

    final bannerImage = Image64.fromBytes(bytes: bytes.buffer.asUint8List());

    // Check if the widget is still mounted before using context
    if (!mounted) return;

    context.read<GameProvider>().updateSelectedGame(userBannerImage: bannerImage);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cover image updated successfully.")),
    );
  }


  /// Picks and crops the cover image with a predefined aspect ratio.
  Future<void> _pickCoverImage() async {
    const aspectRatio = CropAspectRatio(width: 2, height: 3);
    final image = await _pickImage();

    if (image == null) {
      logger.t("No cover image has been selected.");
      return;
    }

    final bytes = await _openCroppyDialog(imageBytes: image, aspectRatio: aspectRatio);
    if (bytes == null) {
      logger.t("User aborted in croppy dialog.");
      return;
    }

    final coverImage = Image64.fromBytes(bytes: bytes.buffer.asUint8List());

    if (!mounted) return;

    context.read<GameProvider>().updateSelectedGame(userCoverImage: coverImage);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Banner image updated successfully.")),
    );
  }


  /// Opens the file picker and returns the selected image as [Uint8List].
  ///
  /// Supports PNG and JPEG formats. Converts JPEG to PNG to ensure compatibility.
  Future<Uint8List?> _pickImage() async {
    try {
      // Open file picker for images
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // --> use FileType.custom to allow custom extensions for more granular control
        allowedExtensions: ["png", "jpeg", "jpg"],
        allowMultiple: false
      );

      if (result != null && result.files.single.path != null) {
        File selectedFile = File(result.files.single.path!);
        Uint8List imageBytes  = await selectedFile.readAsBytes();

        // Convert JPEG/JPG to PNG
        final fileExtension = path.extension(selectedFile.path).toLowerCase();
        if (fileExtension == "jpeg" || fileExtension == "jpg") {
          final img.Image? image = img.decodeJpg(imageBytes );
          if (image == null) {
            _showErrorSnackbar("Failed to decode JPEG image.");
            logger.e("Failed to decode JPEG image.");
            return null;
          }
          imageBytes  = Uint8List.fromList(img.encodePng(image));
          logger.i("Image picked and converted to PNG.");
        }
        else {
          logger.i("Image picked with PNG format.");
        }

        return imageBytes;
      }
    }
    catch (e, stackTrace) {
      _showErrorSnackbar("An error occurred while picking the image.");
      logger.e("Error picking image.", error: e, stackTrace: stackTrace);
      return null;
    }
    _showErrorSnackbar("No image selected.");
    return null;
  }

  /// Opens the Croppy dialog for cropping the image.
  ///
  /// [imageBytes] **MUST** be in PNG format. <br>
  /// Returns the cropped image bytes or null if the user cancels.
  Future<ByteData?> _openCroppyDialog({
    required Uint8List imageBytes,
    required CropAspectRatio aspectRatio
  }) async {
    try {
      final result = await showMaterialImageCropper(
        context,
        imageProvider: MemoryImage(imageBytes),
        allowedAspectRatios: [aspectRatio],
        themeData: Theme.of(context)
      );

      if (result != null) {
        final byteData = await result.uiImage.toByteData(format: ImageByteFormat.png);
        // return byteData?.buffer.asUint8List(); // TODO as uint8list instead of byte data
        return byteData;
      }

    }
    catch (error, stackTrace) {
      _showErrorSnackbar("An error occurred during image cropping.");
      logger.e("Error cropping image.", error: error, stackTrace: stackTrace);
    }
    return null;
  }

  /// Resets the banner image to its default state.
  Future<void> _resetBannerImage() async {
    await context.read<GameProvider>().updateSelectedGame(propertiesToReset: ["userBannerImage"]);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Banner image reset to default.")),
    );
  }

  /// Resets the cover image to its default state.
  Future<void> _resetCoverImage() async {
    await context.read<GameProvider>().updateSelectedGame(propertiesToReset: ["userCoverImage"]);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cover image reset to default.")),
    );
  }

  /// Opens a dialog to edit the game's displayed title.
  Future<void> _editTitle() async {
    final currentTitle = widget.game.displayName;
    final controller = TextEditingController(text: currentTitle);

    final newGameTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Title"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Game Title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = controller.text.trim();
                
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Title cannot be empty.")),
                  );
                  return;
                }
                Navigator.of(context).pop(title); // Save
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newGameTitle != null && newGameTitle != currentTitle) {
      if (!mounted) return;
      await context.read<GameProvider>().updateSelectedGame(userGameTitle: newGameTitle);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Game title updated successfully.")),
      );
    }
  }


  /// Resets the game's displayed title to its default state.
  Future<void> _resetTitle() async {
    await context.read<GameProvider>().updateSelectedGame(propertiesToReset: ["userGameTitle"]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Game title reset to default.")),
    );
  }


  /// Picks the game's executable path based on the current platform.
  Future<void> _pickGamePath() async {
    try {
      // Determine file extension based on platform
      List<String>? allowedExtensions;
      if (Platform.isWindows) {
        allowedExtensions = ['exe'];
      } else if (Platform.isLinux || Platform.isMacOS) {
        allowedExtensions = ['sh'];
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false
      );

      if (result != null && result.files.single.path != null) {
        final uri = result.files.single.path!;
        
        if(!mounted) return;
        await context.read<GameProvider>().updateSelectedGame(userAppUri: uri);

        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game path updated successfully.")),
        );
      }
      else {
        _showErrorSnackbar("No game path selected.");
      }
    } catch (error, stackTrace) {
      _showErrorSnackbar("An error occurred while picking the game path.");
      logger.e("Error picking game path.", error: error, stackTrace: stackTrace);
    }
  }


  /// Resets the game's executable path to its default state.
  Future<void> _resetGamePath() async {
    await context.read<GameProvider>().updateSelectedGame(propertiesToReset: ["userAppUri"]);

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Game path reset to default.")),
    );
  }


  /// Retrieves the application's executable path based on the current platform.
  String _getAppPath() {
    if (Platform.isWindows) {
      return widget.game.userGameSettings.appUri ??
          "${widget.game.uri}\\${widget.game.appTitle}.exe";
    } else if (Platform.isLinux) {
      return widget.game.userGameSettings.appUri ??
          "${widget.game.uri}/${widget.game.appTitle}.sh";
    }
    return "";
  }

  /// Deletes the game files after user confirmation.
  Future<void> _deleteGame() async {
    final direcotryPath = path.dirname(_getAppPath());
    final directory = Directory(direcotryPath);

    if (!directory.existsSync()) {
      _showErrorSnackbar("Game directory does not exist.");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Game"),
          content: const Text(
            "Are you sure you want to delete the game files? This action can NOT be undone!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      try {
        if (!mounted) return;
        await context.read<GameProvider>().deleteSelectedGame();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game deleted successfully.")),
        );
      }
      catch (error, stackTrace) {
        _showErrorSnackbar("Failed to delete the game.");
        logger.e("Error deleting game,", error: error, stackTrace: stackTrace);
      }
    }
  }


  /// Displays an error message using a [SnackBar].
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        SettingsItem(
          title: "Banner Image",
          description: "Pick a new banner image.",
          onPressed: _pickBannerImage,
          onPressed2: _resetBannerImage,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          buttonTextColor: Theme.of(context).colorScheme.onSecondaryContainer,
          buttonText: "Choose Image",
          buttonText2: "Reset",
          hoverText: "Image Displayed On The Top Of The Page.",
          height: 110,
        ),
        SettingsItem(
          title: "Cover Image",
          description: "Pick a new cover image.",
          onPressed: _pickCoverImage,
          onPressed2: _resetCoverImage,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          buttonTextColor: Theme.of(context).colorScheme.onSecondaryContainer,
          buttonText: "Choose Image",
          buttonText2: "Reset",
          hoverText: "Image Displayed On Home Page In The Recommendations.",
          height: 110,
        ),
        SettingsItem(
          title: "Title",
          description: "Edit the displayed game title.",
          onPressed: _editTitle,
          onPressed2: _resetTitle,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          buttonTextColor: Theme.of(context).colorScheme.onSecondaryContainer,
          buttonText: "Edit",
          buttonText2: "Reset",
          hoverText: "Current Title: ${widget.game.displayName}",
          height: 110,
        ),
        SettingsItem(
          title: "Game Path",
          description: "Path to launch the game from.",
          onPressed: _pickGamePath,
          onPressed2: _resetGamePath,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          buttonTextColor: Theme.of(context).colorScheme.onSecondaryContainer,
          buttonText: "Browse",
          buttonText2: "Reset",
          hoverText: "Current Path: ${_getAppPath()}",
          height: 110,
        ),
        SettingsItem(
          title: "Delete Game",
          description: "This will delete all game files.",
          onPressed: _deleteGame,
          buttonBackgroundColor: Theme.of(context).colorScheme.errorContainer,
          buttonTextColor: Theme.of(context).colorScheme.onErrorContainer,
          buttonText: "Delete",
          hoverText: "⚠ Be Careful!",
        ),
        const Divider()
      ],
    );
  }
}


/// A reusable widget for displaying a settings item with optional buttons and hover effects.
class SettingsItem extends StatefulWidget {
  /// The title of the settings item.
  final String title;

  /// The description of the settings item.
  final String? description;

  /// The callback for the primary action button.
  final VoidCallback? onPressed;

  /// The callback for the secondary action button.
  final VoidCallback? onPressed2;

  /// The background color of the primary button.
  final Color? buttonBackgroundColor;

  /// The text for the primary button.
  final String? buttonText;

  /// The text for the secondary button.
  final String? buttonText2;

  /// The text color for the buttons.
  final Color? buttonTextColor;

  /// The height of the settings item container.
  final double height;

  /// The width of the buttons.
  final double buttonWidth;

  /// The height of the buttons.
  final double buttonHeight;

  /// The tooltip message displayed on hover.
  final String? hoverText;

  /// The background color when hovered.
  final Color? hoverColor;

  /// Determines whether to use a dropdown menu instead of buttons.
  final bool useDropDownMenu;

  /// The dropdown button widget to display if [useDropDownMenu] is true.
  final DropdownButton? dropdownButtonWidget;

  const SettingsItem({
    super.key,
    required this.title,
    this.description,
    this.onPressed,
    this.onPressed2,
    this.buttonBackgroundColor,
    this.buttonText,
    this.buttonText2,
    this.buttonTextColor,
    this.height = 70,
    this.buttonWidth = 165,
    this.buttonHeight = 35,
    this.hoverText,
    this.hoverColor,
    this.useDropDownMenu = false,
    this.dropdownButtonWidget
  });

  @override
  SettingsItemState createState() => SettingsItemState();
}

class SettingsItemState extends State<SettingsItem> {
  bool _isHovered = false;

  /// Handles the mouse enter event to update hover state.
  void _onEnter(PointerEvent details) {
    setState(() {
      _isHovered = true;
    });
  }

  /// Handles the mouse exit event to update hover state.
  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
    });
  }

  /// Returns the list of widgets for user input based on [useDropDownMenu].
  List<Widget> _getUserInputWidgets() {
    if (widget.useDropDownMenu) {
      return [widget.dropdownButtonWidget!];
    } else {
      return [
        SizedBox(
          width: widget.buttonWidth,
          height: widget.buttonHeight,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.buttonBackgroundColor,
            ),
            child: Text(
              widget.buttonText ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.buttonTextColor,
              ),
            ),
          ),
        ),
        if (widget.buttonText2 != null) ...[
          SizedBox(
            width: widget.buttonWidth,
            height: widget.buttonHeight,
            child: ElevatedButton(
              onPressed: widget.onPressed2,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.buttonBackgroundColor,
              ),
              child: Text(
                widget.buttonText2!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.buttonTextColor,
                ),
              ),
            ),
          ),
        ],
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.hoverText ?? '',
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        cursor: widget.hoverText == null
          ? MouseCursor.defer
          : SystemMouseCursors.help, // Changes cursor to pointer on hover.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: widget.height,
          decoration: BoxDecoration(
            color: _isHovered
              ? (widget.hoverColor ?? Theme.of(context).colorScheme.inversePrimary)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment:
              CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: widget.description != null
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        widget.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getUserInputWidgets(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
