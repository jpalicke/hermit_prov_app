// ABOUTME: Repository interface for persisting and retrieving per-drill settings.
// ABOUTME: Returns drill defaults when no saved settings exist for a given drill.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

abstract interface class DrillSettingsRepository {
  Future<DrillSettings> getSettings(DrillId drillId);
  Future<void> saveSettings(DrillSettings settings);
  Future<void> resetToDefaults(DrillId drillId);
}
