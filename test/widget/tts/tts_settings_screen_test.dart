// ABOUTME: Widget tests for TtsSettingsScreen — verifies screen renders and slider is present.
// ABOUTME: Uses FakeTtsService via AppServices.withInMemory.

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

  testWidgets('Shows default voice label when no voices available',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // FakeTtsService returns empty voices list, so should show default.
    expect(find.byKey(const Key('tts_voice_default')), findsOneWidget);
  });
}
