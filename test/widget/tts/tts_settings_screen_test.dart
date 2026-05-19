// ABOUTME: Widget tests for TtsSettingsScreen — verifies screen renders and rate slider is present.
// ABOUTME: Uses in-memory AppServices; voice selection has been removed (system default used).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/features/settings/tts_settings_screen.dart';

Widget _wrap() {
  return AppServices.withInMemory(
    child: const MaterialApp(home: TtsSettingsScreen()),
  );
}

void main() {
  testWidgets('TTS settings screen renders with AppBar title', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Text-to-Speech'), findsOneWidget);
  });

  testWidgets('Speaking rate slider is present', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tts_rate_slider')), findsOneWidget);
  });

}
