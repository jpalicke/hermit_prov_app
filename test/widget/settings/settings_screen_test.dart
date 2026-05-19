// ABOUTME: Widget tests for the SettingsScreen covering sections, theme changes, and data resets.
// ABOUTME: Uses in-memory repositories so no real storage is touched during tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
// CatClockSettings is defined in drill_settings.dart (sealed class hierarchy)
import 'package:hermit_prov_app/domain/history/practice_session.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences.dart';
import 'package:hermit_prov_app/domain/settings/app_theme_preference.dart';
import 'package:hermit_prov_app/features/settings/settings_screen.dart';

Widget _wrap(Widget child) {
  return AppServices.withInMemory(
    child: MaterialApp(home: child),
  );
}

void main() {
  group('SettingsScreen sections', () {
    testWidgets('Appearance, Text-to-Speech, and Drill Defaults sections appear',
        (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Text-to-Speech'), findsWidgets);
      expect(find.text('Drill Defaults'), findsOneWidget);
    });
  });

  group('Appearance section', () {
    testWidgets('shows three theme options', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Light saves light theme preference', (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      final saved = await services.appPreferencesRepository.getPreferences();
      expect(saved.themePreference, AppThemePreference.light);
      expect(services.themeNotifier.value, ThemeMode.light);
    });

    testWidgets('tapping Dark saves dark theme preference', (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final saved = await services.appPreferencesRepository.getPreferences();
      expect(saved.themePreference, AppThemePreference.dark);
      expect(services.themeNotifier.value, ThemeMode.dark);
    });
  });

  group('Drill Defaults section', () {
    testWidgets('shows confirmation dialog on tap', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Drill Defaults'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Drill Defaults?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('confirming reset calls resetToDefaults for all drills',
        (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Save a non-default setting for catClock so we can verify the reset.
      const nonDefault = CatClockSettings(
        speakingDuration: Duration(hours: 99),
      );
      await services.drillSettingsRepository.saveSettings(nonDefault);

      await tester.tap(find.text('Reset Drill Defaults'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final restored =
          await services.drillSettingsRepository.getSettings(DrillId.catClock);
      final restored_ = restored as CatClockSettings;
      final defaults_ =
          DrillSettings.defaultsFor(DrillId.catClock) as CatClockSettings;
      expect(restored_.speakingDuration, defaults_.speakingDuration);
    });

    testWidgets('cancelling reset dialog does not change settings',
        (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      const nonDefault = CatClockSettings(
        speakingDuration: Duration(hours: 99),
      );
      await services.drillSettingsRepository.saveSettings(nonDefault);

      await tester.tap(find.text('Reset Drill Defaults'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final settings =
          await services.drillSettingsRepository.getSettings(DrillId.catClock);
      final settings_ = settings as CatClockSettings;
      expect(settings_.speakingDuration, const Duration(hours: 99));
    });
  });

  group('Reset All Data section', () {
    testWidgets('shows confirmation dialog on tap', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('reset_all_data_tile')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset_all_data_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Data?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete All'), findsOneWidget);
    });

    testWidgets('confirming clears history and journal', (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Add a history session and a journal entry.
      final now = DateTime.now();
      await services.practiceHistoryRepository.addSession(
        PracticeSession(
          id: 'session-1',
          drillId: DrillId.catClock,
          startedAt: now,
          duration: const Duration(minutes: 5),
          loggedAt: now,
        ),
      );
      await services.journalRepository.addEntry(
        JournalEntry(
          id: 'entry-1',
          body: 'Some notes',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('reset_all_data_tile')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset_all_data_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete All'));
      await tester.pumpAndSettle();

      final sessions =
          await services.practiceHistoryRepository.getSessions();
      final entries = await services.journalRepository.getEntries();

      expect(sessions, isEmpty);
      expect(entries, isEmpty);
    });

    testWidgets('confirming resets preferences to defaults', (tester) async {
      late AppServices services;

      await tester.pumpWidget(
        AppServices.withInMemory(
          child: Builder(
            builder: (ctx) {
              services = AppServices.of(ctx);
              return const MaterialApp(home: SettingsScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Save a non-default preference.
      await services.appPreferencesRepository.savePreferences(
        const AppPreferences(themePreference: AppThemePreference.dark),
      );

      await tester.scrollUntilVisible(
        find.byKey(const Key('reset_all_data_tile')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset_all_data_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete All'));
      await tester.pumpAndSettle();

      final prefs =
          await services.appPreferencesRepository.getPreferences();
      expect(prefs.themePreference, AppPreferences.defaults.themePreference);
      expect(services.themeNotifier.value, ThemeMode.system);
    });
  });
}
