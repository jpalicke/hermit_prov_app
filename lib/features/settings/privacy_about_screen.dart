// ABOUTME: Privacy and About screen showing data practices, credits, support, and donate links.
// ABOUTME: Uses url_launcher to open mailto and web links from the support and donate sections.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyAboutScreen extends StatelessWidget {
  const PrivacyAboutScreen({super.key});

  static const String _mailtoUrl =
      'mailto:soundonsound78@gmail.com?subject=Hermit Prov%20Feedback&body=App%20version%3A%20%5Bversion%5D%0ADevice%20OS%3A%20%5BOS%5D%0A%0ADescribe%20your%20issue%3A';

  static const String _kofiUrl = 'https://ko-fi.com/joepalicke';

  Future<void> _launchUrl(BuildContext context, String url, String errorMessage) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri);
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and About')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // -- Privacy -------------------------------------------------------
          const _SectionHeader(title: 'Privacy'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hermit Prov does not collect, store, or transmit any personal data. '
              'All data — custom suggestions, journal entries, and practice history — stays on your device.\n\n'
              'Hermit Prov does not record audio and does not request microphone permission.\n\n'
              'No suggestions, journal entries, or practice history are sent anywhere by default. '
              'Data is local-only. Export your data before deleting the app or switching devices.\n\n'
              'Optional crash reports are user-triggered only, and only after a crash. '
              'They include technical details and app state, but never your custom suggestions or journal entries.',
            ),
          ),

          // -- About ---------------------------------------------------------
          const _SectionHeader(title: 'About'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hermit Prov',
              style: textTheme.titleLarge,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'A free, offline-first solo long-form comedy improv practice app.',
            ),
          ),

          // -- Credits -------------------------------------------------------
          const _SectionHeader(title: 'Credits'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hermit Prov is unofficial and unaffiliated with all inspiration sources.',
            ),
          ),
          const ListTile(
            title: Text('Will Hines — Solo Improv Practice'),
            subtitle: Text('willhines.substack.com/p/solo-improv-practice — inspiration for this app.'),
          ),
          const ListTile(
            title: Text('Glenn Trigg Emotion Wheel'),
            subtitle: Text('Licensed CC BY 4.0. Used with attribution.'),
          ),
          const ListTile(
            title: Text('Hermit crab icon'),
            subtitle: Text('Designed by paulalee from Flaticon. Used under Flaticon license with attribution.'),
          ),
          const ListTile(
            title: Text('Cat icon'),
            subtitle: Text('Designed by Marz Gallery from Flaticon. Used under Flaticon license with attribution.'),
          ),

          // -- Support -------------------------------------------------------
          const _SectionHeader(title: 'Support'),
          ListTile(
            title: const Text('Send Feedback'),
            subtitle: const Text('Email the developer'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(
              context,
              _mailtoUrl,
              'Could not open email app.',
            ),
          ),

          // -- Donate --------------------------------------------------------
          const _SectionHeader(title: 'Donate'),
          ListTile(
            title: const Text('Support Development'),
            subtitle: const Text('Ko-fi — no account needed'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(
              context,
              _kofiUrl,
              'Could not open link.',
            ),
          ),

          // -- Disclaimer ----------------------------------------------------
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Hermit Prov is not affiliated with, endorsed by, or officially connected to '
              'any of the inspiration sources listed above.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// -- _SectionHeader ----------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
