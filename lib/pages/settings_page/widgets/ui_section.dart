// ======================================================================
// File: ui_section.dart
// Description: Displays the UI-related settings within the settings
//              section, including theme selection and library
//              management.
//
// Author: dennis828
// Date: 2024-11-17
// ======================================================================


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:boabox/models/user_app_settings.dart';
import 'package:boabox/pages/game_page/widgets/tab_game_settings.dart';
import 'package:boabox/pages/widgets/labeled_divider.dart';
import 'package:boabox/pages/widgets/scrollable_body.dart';
import 'package:boabox/providers/game_provider.dart';
import 'package:boabox/providers/settings_provider.dart';
import 'package:boabox/services/snackbar_service/snackbar_service.dart';


/// A stateless widget that displays the UI-related settings within the settings section.
///
/// The [UiSection] widget includes various settings items such as theme selection,
/// default startup page, internet recommendations, banner actions, library folder management,
/// resyncing the library, and deleting user data.
class UiSection extends StatelessWidget {
  /// Creates a [UiSettingsSection].
  const UiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const ScrollableBody(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LabeledDivider(label: "General"),
                  SettingsItemUiTheme(),
                  SettingsItemDefaultPage(),
                  LabeledDivider(label: "Home"),
                  SettingsItemInternetRecommendations(),
                  SettingsItemBannerAction(),
                  LabeledDivider(label: "Library"),
                  SettingsItemLibraryFolders(),
                  SettingsItemResyncLibrary(),
                  SettingsItemDeleteUserData(),
                  SizedBox(height: 16), // Additional spacing at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A function that displays a dialog to manage library folders.
///
/// The [showFolderDialog] function allows users to add or remove folders that contain their games.
/// It ensures that `BuildContext` is used safely across asynchronous operations by
/// performing a `mounted` check.
Future<void> showFolderDialog(BuildContext context) async {
  final settingsProvider = context.read<SettingsProvider>();
  final gameProvider = context.read<GameProvider>();
  List<String> folders = settingsProvider.libraryDirectories;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Set max width to 80% of screen width
          double maxWidth = MediaQuery.of(context).size.width * 0.8;

          return AlertDialog(
            title: const Text('Manage Folders'),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (folders.isEmpty) const Text('No folders selected.'),
                    ...folders.map((folder) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: folder,
                                child: Text(
                                  folder,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  folders.remove(folder);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Folder'),
                      onPressed: () async {
                        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                        if (selectedDirectory != null && !folders.contains(selectedDirectory)) {
                          setState(() {
                            folders.add(selectedDirectory);
                            settingsProvider.libraryDirectories = folders;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Abort'),
                onPressed: () {
                  Navigator.of(context).pop(); // Don't Save
                },
              ),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  settingsProvider.libraryDirectories = folders;
                  SnackbarService.showSettingSavedSuccess(0);
                  gameProvider.setLibraryDirectories(settingsProvider.libraryDirectories);
                  Navigator.of(context).pop(); // Save & Close
                },
              ),
            ],
          );
        },
      );
    },
  );
}


/// A stateless widget that represents a settings item for UI theme selection.
///
/// The [SettingsItemUiTheme] allows users to select the application's theme from a dropdown menu.
class SettingsItemUiTheme extends StatelessWidget {
  const SettingsItemUiTheme({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SettingsItem(
          title: "UI Theme",
          useDropDownMenu: true,
          dropdownButtonWidget: DropdownButton<ThemeType>(
            value: settingsProvider.currentThemeType,
            icon: const Icon(Icons.arrow_drop_down),
            // elevation: 16,
            alignment: Alignment.center,
            focusColor: Theme.of(context).colorScheme.surface,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onChanged: (ThemeType? value) {
              settingsProvider.updateTheme(value!);
              SnackbarService.showSettingSavedSuccess(0);
            },
            items: const [
              DropdownMenuItem<ThemeType>(
                value: ThemeType.systemDefault,
                child: Text("System Default"),
              ),
              DropdownMenuItem<ThemeType>(
                value: ThemeType.light, child: Text("Light"),
              ),
              DropdownMenuItem<ThemeType>(
                value: ThemeType.dark, child: Text("Dark"),
              ),
            ],
          ),
        ),
      );
    });
  }
}


/// A stateless widget that represents a settings item for selecting the default startup page.
///
/// The [SettingsItemDefaultPage] allows users to choose which page opens on application startup.
class SettingsItemDefaultPage extends StatelessWidget {
  /// Creates a [DefaultStartupPageSettingsItem].
  const SettingsItemDefaultPage({super.key,});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SettingsItem(
            title: "Default Startup Page",
            hoverText: "The page that is opend on startup.",
            useDropDownMenu: true,
            dropdownButtonWidget: DropdownButton<StartPage>(
              value: settingsProvider.selectedPageIndexDefault,
              icon: const Icon(Icons.arrow_drop_down),
              alignment: Alignment.center,
              focusColor: Theme.of(context).colorScheme.surface,
              underline: Container(
                height: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onChanged: (StartPage? value) {
                settingsProvider.selectedPageIndexDefault = value!;
                SnackbarService.showSettingSavedSuccess(0);
              },
              items: const [
                DropdownMenuItem<StartPage>(value: StartPage.home, child: Text("Home")),
                DropdownMenuItem<StartPage>(value: StartPage.library, child: Text("Library")),
                DropdownMenuItem<StartPage>(value: StartPage.settings, child: Text("Settings")),
              ],
            ),
          ),
        );
      }
    );
  }
}


/// A stateless widget that represents a settings item for enabling or disabling internet recommendations.
///
/// The [SettingsItemInternetRecommendations] allows users to toggle internet-based game recommendations.
class SettingsItemInternetRecommendations extends StatelessWidget {
  /// Creates a [SettingsItemInternetRecommendations].
  const SettingsItemInternetRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SettingsItem(
            title: "Internet Recommendations",
            useDropDownMenu: true,
            dropdownButtonWidget: DropdownButton<bool>(
              value: settingsProvider.enableInternetRecommendations,
              icon: const Icon(Icons.arrow_drop_down),
              alignment: Alignment.center,
              focusColor: Theme.of(context).colorScheme.surface,
              underline: Container(
                height: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onChanged: (bool? value) {
                settingsProvider.enableInternetRecommendations = value!;
                SnackbarService.showSettingSavedSuccess(0);
              },
              items: const [
                DropdownMenuItem<bool>(value: true, child: Text("Enabled")),
                DropdownMenuItem<bool>(value: false, child: Text("Disabled")),
              ],
            ),
          ),
        );
      }
    );
  }
}

/// A stateless widget that represents a settings item for banner actions.
///
/// The [SettingsItemBannerAction] allows users to define the behavior when interacting with game banners.
class SettingsItemBannerAction extends StatelessWidget {
  /// Creates a [SettingsItemBannerAction].
  const SettingsItemBannerAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SettingsItem(
          title: "Banner Action",
          hoverText: "Decide what should happen when you click on the game banner.",
          useDropDownMenu: true,
          dropdownButtonWidget: DropdownButton<BannerAction>(
            value: settingsProvider.bannerAction,
            icon: const Icon(Icons.arrow_drop_down),
            alignment: Alignment.center,
            focusColor: Theme.of(context).colorScheme.surface,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onChanged: (BannerAction? value) {
              settingsProvider.bannerAction = value!;
              SnackbarService.showSettingSavedSuccess(0);
            },
            items: const [
              DropdownMenuItem<BannerAction>(value: BannerAction.openLibraryPage, child: Text("Open Library Page")),
              DropdownMenuItem<BannerAction>(value: BannerAction.startGame, child: Text("Start Game")),
            ],
          ),
        ),
      );
    });
  }
}


/// A stateless widget that represents a settings item for managing library folders.
///
/// The [SettingsItemLibraryFolders] allows users to add or remove folders that contain their games.
class SettingsItemLibraryFolders extends StatelessWidget {
  /// Creates a [SettingsItemLibraryFolders].
  const SettingsItemLibraryFolders({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SettingsItem(
            title: "Library Folders",
            hoverText: "Select the folders that contain your games.",
            onPressed: () => showFolderDialog(context),
            buttonText: "Edit",
            buttonBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            buttonTextColor: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        );
      }
    );
  }
}


/// A stateless widget that represents a settings item for resyncing the game library.
///
/// The [SettingsItemResyncLibrary] allows users to manually resync their game library to reflect any changes.
class SettingsItemResyncLibrary extends StatelessWidget {
  /// Creates a [SettingsItemResyncLibrary].
  const SettingsItemResyncLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SettingsItem(
            title: "Rescan Library Folders",
            hoverText: "Check whether games have been added or removed from the library.",
            onPressed: () => gameProvider.resyncGames(),
            buttonText: "Rescan",
            buttonBackgroundColor:
                Theme.of(context).colorScheme.tertiaryContainer,
            buttonTextColor: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        );
      }
    );
  }
}


/// A stateless widget that represents a settings item for deleting user data.
///
/// The [SettingsItemDeleteUserData] allows users to delete their user data, which includes
/// their game library database. This action is irreversible.
class SettingsItemDeleteUserData extends StatelessWidget {
  /// Creates a [SettingsItemDeleteUserData].
  const SettingsItemDeleteUserData({super.key});

  /// Displays a confirmation dialog to delete user data.
  ///
  /// If confirmed, it wipes the database and updates the game library directories.
  Future<void> _wipeDatabase(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User Data"),
          content: const Text("Are you sure you want to delete your user data? This action can NOT be undone!"),
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
      final settingsProvider = context.read<SettingsProvider>();
      final gameProvider = context.read<GameProvider>();
      await settingsProvider.wipeDatabase();
      SnackbarService.showInformation("User data successfully deleted.");
      gameProvider.setLibraryDirectories(settingsProvider.libraryDirectories, reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SettingsItem(
            title: "Delete User Data",
            hoverText: "This will delete the Database containing your user data.",
            onPressed: () => _wipeDatabase(context),
            buttonText: "Delete",
            buttonBackgroundColor: Theme.of(context).colorScheme.errorContainer,
            buttonTextColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
        );
      }
    );
  }
}
