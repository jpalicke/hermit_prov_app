// ABOUTME: Placeholder seed prompts bundled with the app for each prompt category.
// ABOUTME: These are temporary stand-ins; the final lists are a separate content task.

// ⚠️  PLACEHOLDER CONTENT — Replace with human-curated lists before release.

import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

/// Returns the full list of built-in seed prompts across all categories.
List<BuiltInPrompt> buildSeedPrompts() => [
      ..._objects,
      ..._locations,
      ..._relationships,
      ..._occupations,
      ..._emotions,
      ..._activities,
    ];

// ── Objects ───────────────────────────────────────────────────────────────────

const _objects = [
  BuiltInPrompt(id: 'obj-001', text: 'a broken umbrella',    category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-002', text: 'a snow globe',         category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-003', text: 'a half-eaten sandwich', category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-004', text: 'a lava lamp',          category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-005', text: 'a rubber duck',        category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-006', text: 'a trophy',             category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-007', text: 'a garden hose',        category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-008', text: 'a bowling ball',       category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-009', text: 'a typewriter',         category: PromptCategory.objects),
  BuiltInPrompt(id: 'obj-010', text: 'a life preserver',     category: PromptCategory.objects),
];

// ── Locations ─────────────────────────────────────────────────────────────────

const _locations = [
  BuiltInPrompt(id: 'loc-001', text: 'a laundromat',         category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-002', text: 'a rooftop',            category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-003', text: 'a waiting room',       category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-004', text: 'a submarine',          category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-005', text: 'a county fair',        category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-006', text: 'a used car lot',       category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-007', text: 'a lighthouse',         category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-008', text: 'a pawn shop',          category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-009', text: 'a hospital cafeteria', category: PromptCategory.locations),
  BuiltInPrompt(id: 'loc-010', text: 'a treehouse',          category: PromptCategory.locations),
];

// ── Relationships ─────────────────────────────────────────────────────────────

const _relationships = [
  BuiltInPrompt(id: 'rel-001', text: 'estranged siblings',   category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-002', text: 'old rivals',           category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-003', text: 'new neighbors',        category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-004', text: 'a mentor and student', category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-005', text: 'coworkers on a deadline', category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-006', text: 'old friends reuniting', category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-007', text: 'a bad first date',     category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-008', text: 'a coach and player',   category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-009', text: 'landlord and tenant',  category: PromptCategory.relationships),
  BuiltInPrompt(id: 'rel-010', text: 'strangers in an elevator', category: PromptCategory.relationships),
];

// ── Occupations ───────────────────────────────────────────────────────────────

const _occupations = [
  BuiltInPrompt(id: 'occ-001', text: 'a dog groomer',        category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-002', text: 'an air traffic controller', category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-003', text: 'a storm chaser',       category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-004', text: 'a night-shift nurse',  category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-005', text: 'a food critic',        category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-006', text: 'a parking attendant',  category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-007', text: 'a wedding planner',    category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-008', text: 'a magician',           category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-009', text: 'a taxidermist',        category: PromptCategory.occupations),
  BuiltInPrompt(id: 'occ-010', text: 'a sommelier',          category: PromptCategory.occupations),
];

// ── Emotions ──────────────────────────────────────────────────────────────────

const _emotions = [
  BuiltInPrompt(id: 'emo-001', text: 'desperate',            category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-002', text: 'smug',                 category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-003', text: 'overwhelmed',          category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-004', text: 'giddy',                category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-005', text: 'suspicious',           category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-006', text: 'exhausted',            category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-007', text: 'secretly terrified',   category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-008', text: 'bored out of my mind', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-009', text: 'reluctantly proud',    category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-010', text: 'nostalgic',            category: PromptCategory.emotions),
];

// ── Activities ────────────────────────────────────────────────────────────────

const _activities = [
  BuiltInPrompt(id: 'act-001', text: 'moving furniture',     category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-002', text: 'learning to drive',    category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-003', text: 'planning a surprise',  category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-004', text: 'preparing for a storm', category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-005', text: 'waiting for test results', category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-006', text: 'auditioning',          category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-007', text: 'renovating a kitchen', category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-008', text: 'getting lost',         category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-009', text: 'raising money for a cause', category: PromptCategory.activities),
  BuiltInPrompt(id: 'act-010', text: 'cleaning out a storage unit', category: PromptCategory.activities),
];
