// ABOUTME: Widget tests for PrivacyAboutScreen verifying key content sections.
// ABOUTME: Checks privacy assurances, disclaimer, and support/donate tiles are present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/features/settings/privacy_about_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('PrivacyAboutScreen', () {
    testWidgets('shows "No Recording" assurance text', (tester) async {
      await tester.pumpWidget(_wrap(const PrivacyAboutScreen()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('does not record audio'),
        findsOneWidget,
      );
    });

    testWidgets('shows unaffiliated disclaimer', (tester) async {
      await tester.pumpWidget(_wrap(const PrivacyAboutScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('not affiliated with'),
        200,
      );

      expect(
        find.textContaining('not affiliated with'),
        findsOneWidget,
      );
    });

    testWidgets('Support/Feedback tile is present', (tester) async {
      await tester.pumpWidget(_wrap(const PrivacyAboutScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Send Feedback'),
        200,
      );

      expect(find.text('Send Feedback'), findsOneWidget);
      expect(find.text('Email the developer'), findsOneWidget);
    });

    testWidgets('Ko-fi tile is present', (tester) async {
      await tester.pumpWidget(_wrap(const PrivacyAboutScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Support Development'),
        200,
      );

      expect(find.text('Support Development'), findsOneWidget);
      expect(find.text('Ko-fi — no account needed'), findsOneWidget);
    });
  });
}
