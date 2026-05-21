// ABOUTME: Entry point for all built-in seed prompts bundled with the app.
// ABOUTME: Composes per-category lists from the categories/ subdirectory.

import 'package:hermit_prov_app/data/seed/categories/seed_activities.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_emotions.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_events.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_genre.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_locations.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_objects.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_occupations.dart';
import 'package:hermit_prov_app/data/seed/categories/seed_relationships.dart';
import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';

/// Returns the full list of built-in seed prompts across all categories.
List<BuiltInPrompt> buildSeedPrompts() => [
      ...seedObjects,
      ...seedLocations,
      ...seedRelationships,
      ...seedOccupations,
      ...seedEmotions,
      ...seedActivities,
      ...seedGenre,
      ...seedEvents,
    ];
