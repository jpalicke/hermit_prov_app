// ABOUTME: ScreenAwakeService backed by the wakelock_plus plugin.
// ABOUTME: Needs no permission; failures are swallowed because a missing wakelock must never crash a drill.

import 'package:hermit_prov_app/domain/device/screen_awake_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockScreenAwakeService implements ScreenAwakeService {
  const WakelockScreenAwakeService();

  @override
  Future<void> keepAwake() async {
    try {
      await WakelockPlus.enable();
    } on Object {
      // The drill still works without a wakelock; the screen may just lock.
    }
  }

  @override
  Future<void> allowSleep() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // Nothing to undo if the wakelock could not be changed.
    }
  }
}
