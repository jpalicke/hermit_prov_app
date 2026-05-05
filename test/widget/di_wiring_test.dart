// ABOUTME: Widget smoke test verifying AppServices mounts cleanly around the app.
// ABOUTME: Proves the DI container is accessible from within the widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/ui/navigation/bottom_nav_shell.dart';

void main() {
  group('AppServices DI wiring', () {
    testWidgets('app launches cleanly when wrapped with AppServices.withInMemory',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        AppServices.withInMemory(child: const HermitProvApp()),
      );
      expect(find.byType(BottomNavShell), findsOneWidget);
    });

    testWidgets('AppServices.of is accessible from a widget in the tree',
        (WidgetTester tester) async {
      AppServices? captured;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (context) {
              captured = AppServices.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.promptRepository, isNotNull);
      expect(captured!.drillSettingsRepository, isNotNull);
      expect(captured!.practiceHistoryRepository, isNotNull);
      expect(captured!.journalRepository, isNotNull);
      expect(captured!.appPreferencesRepository, isNotNull);
    });
  });
}
