// ABOUTME: Model representing a single logged practice session.
// ABOUTME: Sessions are only logged when the user practices for at least 30 seconds.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.drillId,
    required this.startedAt,
    required this.duration,
  });

  final String id;
  final DrillId drillId;
  final DateTime startedAt;
  final Duration duration;
}
