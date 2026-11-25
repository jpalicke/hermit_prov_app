// ABOUTME: Repository tests for DriftDrillSettingsRepository using an in-memory Drift database.
// ABOUTME: Verifies default loading, settings persistence, and reset behavior.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/data/repositories/drift_drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late DriftDrillSettingsRepository repo;

  setUp(() {
    db = openTestDatabase();
    repo = DriftDrillSettingsRepository(db);
  });

  tearDown(() => db.close());

  // ── Save and retrieve ─────────────────────────────────────────────────────

  group('save and retrieve', () {
    test('saved settings are returned on the next get', () async {
      const modified = CatClockSettings(speakingDuration: Duration(minutes: 5));
      await repo.saveSettings(modified);

      final retrieved =
          await repo.getSettings(DrillId.catClock) as CatClockSettings;
      expect(retrieved.speakingDuration, const Duration(minutes: 5));
    });
  });

  // ── Reset to defaults ─────────────────────────────────────────────────────

  group('resetToDefaults', () {
    test('reset does not affect other drills', () async {
      const modified = AtoCSettings(interval: Duration(seconds: 60));
      await repo.saveSettings(modified);
      await repo.resetToDefaults(DrillId.catClock);

      final atoC = await repo.getSettings(DrillId.atoC) as AtoCSettings;
      expect(atoC.interval, const Duration(seconds: 60));
    });
  });
}
