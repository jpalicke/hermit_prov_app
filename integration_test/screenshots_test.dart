// ABOUTME: Integration test that navigates to key screens for App Store screenshots.
// ABOUTME: Coordinates with the screenshots workflow via tmp file sentinels.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture App Store screenshots', (tester) async {
    final app = await AppServices.withLocalStorage(child: const HermitProvApp());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 1. Practice home — the drill list.
    await _capture(tester, '01_practice_home');

    // 2. Five Line configure screen.
    await tester.scrollUntilVisible(
      find.byKey(const Key('drill_card_configure_fiveLineGame')),
      150,
    );
    await tester.tap(find.byKey(const Key('drill_card_configure_fiveLineGame')));
    await tester.pumpAndSettle();
    await _capture(tester, '02_five_line_configure');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // 3. Five Line session — tap the card to start, wait for suggestion to load.
    await tester.scrollUntilVisible(find.text('Five Line Scenes'), 150);
    await tester.tap(find.text('Five Line Scenes').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _capture(tester, '03_five_line_session');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Tools screen.
    await tester.scrollUntilVisible(find.text('Tools'), 150);
    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    await _capture(tester, '04_tools');

    // 5. Suggestion Generator — tap New Suggestion so one is showing.
    await tester.tap(find.text('Suggestion Generator'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Suggestion'));
    await tester.pumpAndSettle();
    await _capture(tester, '05_suggestion_generator');
  });
}

/// Writes a ready sentinel, waits for the workflow to take a screenshot and
/// signal done, then removes the done sentinel before continuing.
Future<void> _capture(WidgetTester tester, String name) async {
  final tmp = Directory.systemTemp.path;
  final ready = File('$tmp/${name}_ready');
  final done = File('$tmp/${name}_done');
  await ready.writeAsString('ready');
  while (!done.existsSync()) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await done.delete();
}
