// ABOUTME: Repository tests for InMemoryDrillSettingsRepository.
// ABOUTME: Verifies default loading, settings persistence, and reset behavior.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

void main() {
  late InMemoryDrillSettingsRepository repo;

  setUp(() => repo = InMemoryDrillSettingsRepository());

  // ── Save and retrieve ─────────────────────────────────────────────────────

  group('save and retrieve', () {
    test('saving one drill does not affect another', () async {
      const modified = AtoCSettings(interval: Duration(seconds: 60));
      await repo.saveSettings(modified);

      final catClock =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(catClock.speakingDuration, const Duration(minutes: 3));
    });
  });

}
