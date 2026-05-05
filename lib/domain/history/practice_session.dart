// ABOUTME: Model representing a single logged practice session.
// ABOUTME: Sessions are only logged when the user practices for at least 30 seconds.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.drillId,
    required this.startedAt,
    required this.duration,
    required this.loggedAt,
  });

  final String id;
  final DrillId drillId;
  final DateTime startedAt;
  final Duration duration;

  /// When the session was persisted (after the 30-second threshold was crossed).
  /// Distinct from [startedAt] to correctly attribute midnight-spanning sessions
  /// to the right calendar day for streak calculations.
  final DateTime loggedAt;
}
