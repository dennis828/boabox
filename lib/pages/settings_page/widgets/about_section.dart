// ======================================================================
// File: about_section.dart
// Description: Displays the "About" section within the settings,
//              including app information and donation options.
//
// Author: Your Name
// Date: 2024-11-17
// ======================================================================


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:boabox/utils/open_webbrowser/open_webbrowser.dart';

/// A stateless widget that displays the "About" section within the settings.
///
/// The [AboutSection] widget provides information about the application,
/// options to donate, and links to feedback channels such as Reddit and GitHub.
/// It includes buttons for donations and viewing version & license information.
class AboutSection extends StatelessWidget {
  /// Creates an [AboutSection].
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double contentWidth = MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: Container(
        width: contentWidth,
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank you for using BoaBox!',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            AboutSectionText(),
            SizedBox(height: 20),
            DonationButton(),
            SizedBox(height: 20),
            VersionAndLicensesButton()
          ],
        ),
      ),
    );
  }
}


/// A stateless widget that displays detailed information and links in the "About" section.
///
/// The [AboutSectionText] widget uses [RichText] to format the text with different styles
/// and includes tappable links to Reddit and GitHub for user feedback.
class AboutSectionText extends StatelessWidget {
  const AboutSectionText({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.secondary
    );
    final boldStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.bold
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
              text: "I hope you're ",
              style: defaultStyle),
          TextSpan(
            text: 'enjoying',
            style: boldStyle,
          ),
          TextSpan(
              text: " my app! If so, I'd love to hear any ",
              style: defaultStyle),
          TextSpan(
            text: 'feedback',
            style: boldStyle,
          ),
          const TextSpan(
            text: " from you on improvements or features you'd like to see added. You can provide feedback ",
          ),
          TextSpan(
            text: '@dennis_828 on reddit',
            style: linkStyle,
            mouseCursor: SystemMouseCursors.click,
            recognizer: TapGestureRecognizer()
            ..onTap = () {
              openWebBrowser("https://reddit.com/u/dennis_828");
            },
          ),
          const TextSpan(text: ' or through the '),
          TextSpan(
            text: 'GitHub repository',
            style: linkStyle,
            mouseCursor: SystemMouseCursors.click,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openWebBrowser("https://github.com/dennis_828/boabox");
            },
          ),
          const TextSpan(text: ".\nIf you'd like to "),
          TextSpan(
            text: 'support',
            style: boldStyle,
          ),
          TextSpan(
            text: " my development, please consider making a donation using the button below.",
            style: defaultStyle),
        ],
      ),
    );
  }
}


/// A stateless widget that displays a donation button labeled "🍺 Buy Me a Beer".
///
/// The [DonationButton] widget allows users to support the developer by redirecting
/// them to a donation page.
class DonationButton extends StatelessWidget {
  /// Creates a [DonationButton].
  const DonationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '🍺 buy me a beer',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer,
      ),
      onPressed: () {
        openWebBrowser("https://buymeacoffee.com/dennis828");
      },
    );
  }
}


/// A stateful widget that displays a button to view version and license information.
///
/// The [VersionAndLicensesButton] widget fetches the app's version information
/// and displays it along with license details in a dialog when pressed.
class VersionAndLicensesButton extends StatefulWidget {
  /// Creates a [VersionAndLicensesButton].
  const VersionAndLicensesButton({super.key});

  @override
  VersionAndLicensesButtonState createState() => VersionAndLicensesButtonState();
}

class VersionAndLicensesButtonState
    extends State<VersionAndLicensesButton> {
  /// Retrieves the package information asynchronously.
  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        'Version & Licenses',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onPressed: () async {
        PackageInfo packageInfo = await _getPackageInfo();

        // Check if the widget is still mounted before using context
        if (!mounted) return;

        showAboutDialog(
          // ignore: use_build_context_synchronously <-- is checked in line 189
          context: context,
          applicationName: packageInfo.appName,
          applicationVersion: "${packageInfo.version}+${packageInfo.buildNumber}",
          applicationLegalese: '© 2024 dennis828',
        );
      },
    );
  }
}
