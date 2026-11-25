// ABOUTME: Pins the stored JSON format of every DrillSettings subclass with fixed fixtures.
// ABOUTME: Renaming a key or changing a fallback would silently reset saved settings and old backups.

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings.dart';

// Non-default values in the exact shape the database and backups store.
const _stored = <DrillId, Map<String, dynamic>>{
  DrillId.catClock: {
    'speakingDuration': 120000,
    'regroupDuration': 15000,
    'prompt1Categories': ['emotions'],
    'prompt2Categories': ['locations', 'genre'],
    'handsFreeModeEnabled': true,
  },
  DrillId.characterCreation: {
    'characterCount': 4,
    'segmentDuration': 90000,
    'promptCategories': ['occupations'],
    'handsFreeModeEnabled': true,
  },
  DrillId.twoCharacterScenes: {
    'sceneDuration': 120000,
    'regroupDuration': 45000,
    'promptCategories': ['relationships'],
    'handsFreeModeEnabled': true,
  },
  DrillId.atoC: {
    'interval': 45000,
    'promptCategories': ['events'],
    'handsFreeModeEnabled': true,
  },
  DrillId.fiveLineGame: {
    'autoAdvance': true,
    'autoAdvanceInterval': 60000,
    'promptCategories': ['activities'],
    'handsFreeModeEnabled': true,
  },
};

void main() {
  test('stored JSON decodes to the expected values for every drill', () {
    final cat = DrillSettings.fromJson(
      DrillId.catClock,
      _stored[DrillId.catClock]!,
    ) as CatClockSettings;
    expect(cat.speakingDuration, const Duration(minutes: 2));
    expect(cat.regroupDuration, const Duration(seconds: 15));
    expect(cat.prompt1Categories.map((c) => c.name), ['emotions']);
    expect(cat.prompt2Categories.map((c) => c.name), ['locations', 'genre']);

    final cc = DrillSettings.fromJson(
      DrillId.characterCreation,
      _stored[DrillId.characterCreation]!,
    ) as CharacterCreationSettings;
    expect(cc.characterCount, 4);
    expect(cc.segmentDuration, const Duration(seconds: 90));
    expect(cc.promptCategories.map((c) => c.name), ['occupations']);

    final two = DrillSettings.fromJson(
      DrillId.twoCharacterScenes,
      _stored[DrillId.twoCharacterScenes]!,
    ) as TwoCharacterScenesSettings;
    expect(two.sceneDuration, const Duration(seconds: 120));
    expect(two.regroupDuration, const Duration(seconds: 45));
    expect(two.promptCategories.map((c) => c.name), ['relationships']);

    final atoc = DrillSettings.fromJson(
      DrillId.atoC,
      _stored[DrillId.atoC]!,
    ) as AtoCSettings;
    expect(atoc.interval, const Duration(seconds: 45));
    expect(atoc.promptCategories.map((c) => c.name), ['events']);

    final five = DrillSettings.fromJson(
      DrillId.fiveLineGame,
      _stored[DrillId.fiveLineGame]!,
    ) as FiveLineGameSettings;
    expect(five.autoAdvance, isTrue);
    expect(five.autoAdvanceInterval, const Duration(seconds: 60));
    expect(five.promptCategories.map((c) => c.name), ['activities']);

    for (final id in DrillId.values) {
      final s = DrillSettings.fromJson(id, _stored[id]!);
      expect(s.drillId, id);
      expect(s.handsFreeModeEnabled, isTrue, reason: '$id');
    }
  });

  test('toJson writes exactly the stored keys and values for every drill', () {
    for (final id in DrillId.values) {
      final json = DrillSettings.fromJson(id, _stored[id]!).toJson();
      expect(json, _stored[id], reason: '$id');
    }
  });

  test('settings saved before hands-free existed load with it off', () {
    for (final id in DrillId.values) {
      final legacy = Map<String, dynamic>.of(_stored[id]!)
        ..remove('handsFreeModeEnabled');
      expect(
        DrillSettings.fromJson(id, legacy).handsFreeModeEnabled,
        isFalse,
        reason: '$id',
      );
    }
  });

  test('Five Line with auto-advance off stores and loads a null interval', () {
    const settings = FiveLineGameSettings();
    final json = settings.toJson();
    expect(json['autoAdvanceInterval'], isNull);
    final back = DrillSettings.fromJson(DrillId.fiveLineGame, json)
        as FiveLineGameSettings;
    expect(back.autoAdvance, isFalse);
    expect(back.autoAdvanceInterval, isNull);
  });
}
