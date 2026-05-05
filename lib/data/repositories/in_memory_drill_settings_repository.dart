// ABOUTME: In-memory implementation of DrillSettingsRepository.
// ABOUTME: Returns drill defaults when no saved settings exist for a given drill.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';

class InMemoryDrillSettingsRepository implements DrillSettingsRepository {
  final Map<DrillId, DrillSettings> _saved = {};

  @override
  Future<DrillSettings> getSettings(DrillId drillId) async {
    return _saved[drillId] ?? DrillSettings.defaultsFor(drillId);
  }

  @override
  Future<void> saveSettings(DrillSettings settings) async {
    _saved[settings.drillId] = settings;
  }

  @override
  Future<void> resetToDefaults(DrillId drillId) async {
    _saved.remove(drillId);
  }
}
