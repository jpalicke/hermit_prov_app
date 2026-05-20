// ABOUTME: Enum of the eight prompt categories used throughout the app.
// ABOUTME: The wordBucket constant represents all categories combined.

enum PromptCategory {
  objects,
  locations,
  relationships,
  occupations,
  emotions,
  activities,
  genre,
  events;

  /// All eight categories combined. Used as the default prompt source for every drill.
  /// Must list every enum value explicitly because const lists cannot use `values`.
  /// The word_bucket_test.dart unit test guards against divergence when values are added.
  static const List<PromptCategory> wordBucket = [
    objects,
    locations,
    relationships,
    occupations,
    emotions,
    activities,
    genre,
    events,
  ];

  /// Human-readable label suitable for chips and list headers.
  String get displayLabel => switch (this) {
    PromptCategory.objects => 'Objects',
    PromptCategory.locations => 'Locations',
    PromptCategory.relationships => 'Relationships',
    PromptCategory.occupations => 'Occupations',
    PromptCategory.emotions => 'Emotions',
    PromptCategory.activities => 'Activities',
    PromptCategory.genre => 'Genre',
    PromptCategory.events => 'Events',
  };
}
