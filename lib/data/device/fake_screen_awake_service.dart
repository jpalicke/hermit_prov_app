// ABOUTME: In-memory ScreenAwakeService for tests and in-memory app wiring.
// ABOUTME: Records whether the screen is being held awake without touching any platform plugin.

import 'package:hermit_prov_app/domain/device/screen_awake_service.dart';

class FakeScreenAwakeService implements ScreenAwakeService {
  /// Whether the screen is currently being held awake.
  bool isAwake = false;

  /// Number of times [keepAwake] has been called.
  int keepAwakeCount = 0;

  @override
  Future<void> keepAwake() async {
    keepAwakeCount++;
    isAwake = true;
  }

  @override
  Future<void> allowSleep() async {
    isAwake = false;
  }
}
