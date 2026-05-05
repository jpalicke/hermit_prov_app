// ABOUTME: Repository tests for InMemoryDrillSettingsRepository.
// ABOUTME: Verifies default loading, settings persistence, and reset behavior.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

void main() {
  late InMemoryDrillSettingsRepository repo;

  setUp(() => repo = InMemoryDrillSettingsRepository());

  // ── Defaults ──────────────────────────────────────────────────────────────

  group('default settings', () {
    test('returns a DrillSettings for every DrillId before any save', () async {
      for (final drillId in DrillId.values) {
        final settings = await repo.getSettings(drillId);
        expect(settings.drillId, drillId);
      }
    });

    test('Cat/Clock default speaking duration is 3 minutes', () async {
      final settings =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(settings.speakingDuration, const Duration(minutes: 3));
    });

    test('Cat/Clock default regroup duration is 30 seconds', () async {
      final settings =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(settings.regroupDuration, const Duration(seconds: 30));
    });

    test('A-to-C default interval is 30 seconds', () async {
      final settings =
          await repo.getSettings(DrillId.atoC) as AtoCSettings;
      expect(settings.interval, const Duration(seconds: 30));
    });
  });

  // ── Save and retrieve ─────────────────────────────────────────────────────

  group('save and retrieve', () {
    test('saved settings are returned on the next get', () async {
      const modified = CatClockSettings(speakingDuration: Duration(minutes: 5));
      await repo.saveSettings(modified);

      final retrieved =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(retrieved.speakingDuration, const Duration(minutes: 5));
    });

    test('saving one drill does not affect another', () async {
      const modified = AtoCSettings(interval: Duration(seconds: 60));
      await repo.saveSettings(modified);

      final catClock =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(catClock.speakingDuration, const Duration(minutes: 3));
    });

    test('multiple saves overwrite the previous value', () async {
      await repo.saveSettings(const CatClockSettings(speakingDuration: Duration(minutes: 5)));
      await repo.saveSettings(const CatClockSettings(speakingDuration: Duration(minutes: 2)));

      final retrieved =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(retrieved.speakingDuration, const Duration(minutes: 2));
    });
  });

  // ── Reset to defaults ─────────────────────────────────────────────────────

  group('resetToDefaults', () {
    test('restores default speaking duration after a save', () async {
      await repo.saveSettings(
          const CatClockSettings(speakingDuration: Duration(minutes: 5)));
      await repo.resetToDefaults(DrillId.catClock);

      final restored =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(restored.speakingDuration, const Duration(minutes: 3));
    });

    test('reset does not affect other drills', () async {
      const modified = AtoCSettings(interval: Duration(seconds: 60));
      await repo.saveSettings(modified);
      await repo.resetToDefaults(DrillId.catClock);

      final atoC = await repo.getSettings(DrillId.atoC) as AtoCSettings;
      expect(atoC.interval, const Duration(seconds: 60));
    });
  });
}
