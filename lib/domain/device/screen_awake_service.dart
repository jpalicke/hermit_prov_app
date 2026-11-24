// ABOUTME: Abstraction for keeping the device screen on while a drill session runs.
// ABOUTME: Lets the session shell hold the screen awake without depending on a plugin directly.

/// Keeps the screen from auto-locking while a session is running.
///
/// Hands-free drills are used without touching the phone, so without this the
/// screen locks, the OS suspends the app, and the timer and TTS stop.
abstract class ScreenAwakeService {
  /// Keeps the screen on until [allowSleep] is called.
  Future<void> keepAwake();

  /// Lets the screen auto-lock normally again.
  Future<void> allowSleep();
}
