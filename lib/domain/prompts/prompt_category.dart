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
}
