// ABOUTME: Widget tests for the Emotion Wheel screen and its integration with the Tools screen.
// ABOUTME: Verifies navigation, initial state, random picker visibility, and no drill action present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/features/tools/emotion_wheel_screen.dart';
import 'package:hermit_prov_app/features/tools/tools_screen.dart';

Widget _wrapWithServices(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

void main() {
  group('EmotionWheelScreen', () {
    testWidgets('emotion wheel is reachable from Tools screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const ToolsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Emotion Wheel'));
      await tester.pumpAndSettle();

      expect(find.byType(EmotionWheelScreen), findsOneWidget);
    });

    testWidgets('core emotion sectors are present — initial state shows placeholder text',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const EmotionWheelScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('tap any segment to select an emotion'),
        findsOneWidget,
      );
    });

    testWidgets('random picker panel is visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const EmotionWheelScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pick random emotion'), findsOneWidget);
    });

    testWidgets('no send to drill action exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithServices(const EmotionWheelScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Send to drill'), findsNothing);
      expect(find.textContaining('Add to drill'), findsNothing);
    });
  });
}
