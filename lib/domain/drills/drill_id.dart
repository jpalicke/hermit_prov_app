// ABOUTME: Enum identifying each of the five drills in the app.
// ABOUTME: Includes a displayName extension for authoritative human-readable drill names.

enum DrillId {
  catClock,
  characterCreation,
  twoCharacterScenes,
  atoC,
  fiveLineGame,
}

extension DrillIdDisplayName on DrillId {
  /// The canonical display name shown in the UI for this drill.
  String get displayName => switch (this) {
        DrillId.catClock => 'Cat/Clock',
        DrillId.characterCreation => 'Character Creation',
        DrillId.twoCharacterScenes => 'Two-Character Scenes',
        DrillId.atoC => 'A-to-C / Bad Idea / Initiation',
        DrillId.fiveLineGame => 'Five Line Scenes',
      };
}
