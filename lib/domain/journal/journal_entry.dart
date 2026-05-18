// ABOUTME: Model for a single user-written practice journal entry.
// ABOUTME: Entries may optionally be tagged with a drill but are never required to be.

import 'package:hermit_prov_app/domain/drills/drill_id.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.drillId,
  });

  final String id;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DrillId? drillId;

  JournalEntry copyWith({
    String? id,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? drillId = _sentinel,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      drillId: drillId == _sentinel ? this.drillId : drillId as DrillId?,
    );
  }
}

// Sentinel object used to distinguish "not provided" from explicit null in copyWith.
const Object _sentinel = Object();
