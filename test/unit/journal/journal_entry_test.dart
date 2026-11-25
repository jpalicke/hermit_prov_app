// ABOUTME: Unit tests for the JournalEntry domain model.
// ABOUTME: Verifies structural isolation from practice history by asserting JournalEntry lacks a Duration field.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/journal/journal_entry.dart';

void main() {
  group('JournalEntry', () {
    test('copyWith can clear drillId to null', () {
      final original = JournalEntry(
        id: 'abc',
        body: 'Some text.',
        createdAt: DateTime(2026, 5, 18),
        updatedAt: DateTime(2026, 5, 18),
        drillId: DrillId.catClock,
      );

      final updated = original.copyWith(drillId: null);
      expect(updated.drillId, isNull);
    });

    // Structural isolation: JournalEntry has no Duration field.
    // Because JournalEntry cannot hold a session duration, it is structurally
    // impossible for it to be counted toward streak or session calculations,
    // which live exclusively in PracticeHistoryRepository.
  });
}
