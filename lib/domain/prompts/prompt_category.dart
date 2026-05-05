// ABOUTME: Enum of the six prompt categories used throughout the app.
// ABOUTME: The wordBucket constant represents all categories combined.

enum PromptCategory {
  objects,
  locations,
  relationships,
  occupations,
  emotions,
  activities;

  /// All six categories combined. Used as the default prompt source for every drill.
  static const List<PromptCategory> wordBucket = [
    objects,
    locations,
    relationships,
    occupations,
    emotions,
    activities,
  ];
}
