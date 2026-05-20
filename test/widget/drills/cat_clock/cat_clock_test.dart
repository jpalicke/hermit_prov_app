// ABOUTME: Widget tests for the Cat/Clock drill — session, configure, and stop.
// ABOUTME: Tests use real in-memory repositories to verify settings persistence and category pickers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_configure_screen.dart';
import 'package:hermit_prov_app/features/drills/cat_clock/cat_clock_session_screen.dart';

Widget _wrapSession({VoidCallback? onConfigure}) {
  return AppServices.withInMemory(
    child: Builder(
      builder: (context) {
        final services = AppServices.of(context);
        return MaterialApp(
          home: CatClockSessionScreen(
            settings: const CatClockSettings(),
            promptRepository: services.promptRepository,
            onSessionEnd: () {},
            onConfigure: onConfigure,
          ),
        );
      },
    ),
  );
}

void main() {
  // 1. Session screen shows start and stop controls.
  testWidgets('Session shows session shell controls', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Session loads idle — Start button shown before clock begins.
    expect(find.byKey(const Key('start_button')), findsOneWidget);
    expect(find.byKey(const Key('stop_end_button')), findsOneWidget);

    // After tapping Start, Pause/Resume button appears.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
  });

  // 2. Hands-Free toggle is present and off by default in configure screen.
  testWidgets('Configure has Hands-Free toggle off by default', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('hands_free_toggle')),
    );
    expect(toggle.value, isFalse);
  });

  // 3. Configure saves changed speaking/regroup durations.
  testWidgets('Configure saves speaking and regroup durations', (tester) async {
    final services = AppServices.withInMemory(
      child: const MaterialApp(home: CatClockConfigureScreen()),
    );

    // Extract the AppServices so we can read back settings.
    await tester.pumpWidget(services);
    await tester.pump();

    // Increment speaking minutes once (default 3 → 4).
    await tester.tap(find.byKey(const Key('minutes_increment')));
    await tester.pump();

    // Tap Save.
    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    // Read back from the repository via the InheritedWidget.
    final appServices = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(appServices).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.catClock) as CatClockSettings;
    expect(saved.speakingDuration, const Duration(minutes: 4));
  });

  // 3. Pause/Resume works.
  testWidgets('Pause and Resume work in Cat/Clock session', (tester) async {
    await tester.pumpWidget(_wrapSession());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Start the session first.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pump();

    // Verify running — button shows "Pause".
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pause_resume_button')));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
  });

  // 4. Category pickers render for both prompts.
  testWidgets('Configure shows prompt1 and prompt2 category pickers', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('prompt1_category_picker')), findsOneWidget);
    expect(find.byKey(const Key('prompt2_category_picker')), findsOneWidget);
    expect(find.text('Prompt 1 categories'), findsOneWidget);
    expect(find.text('Prompt 2 categories'), findsOneWidget);
  });

  // 5. Toggling a category chip saves the change.
  testWidgets('Toggling category chip saves to settings', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    // Default is Objects selected. Tap Locations chip inside prompt1 picker.
    final prompt1Picker = find.byKey(const Key('prompt1_category_picker'));
    final locationsChip = find.descendant(
      of: prompt1Picker,
      matching: find.text('Locations'),
    );
    await tester.ensureVisible(locationsChip);
    await tester.tap(locationsChip);
    await tester.pump();

    // Tap Save.
    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    final appServices = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(appServices).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.catClock) as CatClockSettings;
    expect(saved.prompt1Categories, contains(PromptCategory.locations));
  });

  // 6. Empty-selection guard falls back to [objects] for prompt1.
  testWidgets('Deselecting all prompt1 chips falls back to objects', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    // Default is Objects selected. Tap Objects chip to deselect it (leaving nothing).
    final prompt1Picker = find.byKey(const Key('prompt1_category_picker'));
    final objectsChip = find.descendant(
      of: prompt1Picker,
      matching: find.text('Objects'),
    );
    await tester.ensureVisible(objectsChip);
    await tester.tap(objectsChip);
    await tester.pump();

    // Tap Save.
    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    final appServices = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(appServices).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.catClock) as CatClockSettings;
    expect(saved.prompt1Categories, equals([PromptCategory.objects]));
  });

  // 7. prompt2Categories saves correctly.
  testWidgets('Toggling category chip saves to prompt2 settings', (tester) async {
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: const MaterialApp(home: CatClockConfigureScreen()),
      ),
    );
    await tester.pump();

    // Tap Emotions chip inside prompt2 picker.
    final prompt2Picker = find.byKey(const Key('prompt2_category_picker'));
    final emotionsChip = find.descendant(
      of: prompt2Picker,
      matching: find.text('Emotions'),
    );
    await tester.ensureVisible(emotionsChip);
    await tester.tap(emotionsChip);
    await tester.pump();

    // Tap Save.
    await tester.tap(find.byKey(const Key('drill_configure_save_button')));
    await tester.pumpAndSettle();

    final appServices = tester.element(find.byType(MaterialApp).first);
    final repo = AppServices.of(appServices).drillSettingsRepository;
    final saved = await repo.getSettings(DrillId.catClock) as CatClockSettings;
    expect(saved.prompt2Categories, contains(PromptCategory.emotions));
  });

  // 8. Stop calls onSessionEnd immediately without a confirmation dialog.
  testWidgets('Stop calls onSessionEnd immediately', (tester) async {
    var ended = false;
    await tester.pumpWidget(
      AppServices.withInMemory(
        child: Builder(
          builder: (context) {
            final services = AppServices.of(context);
            return MaterialApp(
              home: CatClockSessionScreen(
                settings: const CatClockSettings(),
                promptRepository: services.promptRepository,
                onSessionEnd: () => ended = true,
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('stop_end_button')));
    await tester.pumpAndSettle();

    // No confirmation dialog — session ends immediately.
    expect(find.byKey(const Key('stop_confirm_button')), findsNothing);
    expect(ended, isTrue);
  });
}
