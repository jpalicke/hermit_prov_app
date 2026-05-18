// ABOUTME: Drift-backed implementation of DrillSettingsRepository for on-device persistence.
// ABOUTME: Settings are stored as JSON blobs in SQLite; defaults are returned when no row exists.

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hermit_prov_app/data/local/app_database.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';

class DriftDrillSettingsRepository implements DrillSettingsRepository {
  DriftDrillSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<DrillSettings> getSettings(DrillId drillId) async {
    final row = await (_db.select(_db.drillSettingsTable)
          ..where((t) => t.drillId.equals(drillId.name)))
        .getSingleOrNull();
    if (row == null) return DrillSettings.defaultsFor(drillId);
    final json = jsonDecode(row.settingsJson) as Map<String, dynamic>;
    return DrillSettings.fromJson(drillId, json);
  }

  @override
  Future<void> saveSettings(DrillSettings settings) async {
    await _db.into(_db.drillSettingsTable).insertOnConflictUpdate(
          DrillSettingsTableCompanion(
            drillId: Value(settings.drillId.name),
            settingsJson: Value(jsonEncode(settings.toJson())),
          ),
        );
  }

  @override
  Future<void> resetToDefaults(DrillId drillId) async {
    await (_db.delete(_db.drillSettingsTable)
          ..where((t) => t.drillId.equals(drillId.name)))
        .go();
  }
}
