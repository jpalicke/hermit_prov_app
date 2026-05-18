// ABOUTME: Built-in seed prompts for the Emotions category.
// ABOUTME: 109 unique words deduped from the Glenn Trigg Emotion Wheel (CC BY 4.0).

import 'package:hermit_prov_app/domain/prompts/built_in_prompt.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_category.dart';

// Credit: Glenn Trigg Emotion Wheel, licensed CC BY 4.0.
// Source: https://commons.wikimedia.org/wiki/File:The_Feeling_Wheel.png
// Deduplication: insecure (Fear mid / Anger outer), inferior (Fear outer / Sad outer),
//                abandoned (Sad mid / Sad outer), inadequate (appears twice in Fear outer)
//                → each retained once in the sector listed below.

const List<BuiltInPrompt> seedEmotions = [
  // ── FEAR ─────────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-001', text: 'fearful', category: PromptCategory.emotions),

  // Middle (6)
  BuiltInPrompt(id: 'emo-002', text: 'scared', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-003', text: 'anxious', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-004', text: 'insecure', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-005', text: 'submissive', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-006', text: 'rejected', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-007', text: 'humiliated', category: PromptCategory.emotions),

  // Outer (11 unique — inadequate appears twice on wheel, inferior also in Sad outer)
  BuiltInPrompt(id: 'emo-008', text: 'terrified', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-009', text: 'frightened', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-010', text: 'overwhelmed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-011', text: 'worried', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-012', text: 'worthless', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-013', text: 'insignificant', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-014', text: 'inadequate', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-015', text: 'inferior', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-016', text: 'alienated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-017', text: 'disrespected', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-018', text: 'ridiculed', category: PromptCategory.emotions),

  // ── ANGER ─────────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-019', text: 'angry', category: PromptCategory.emotions),

  // Middle (8)
  BuiltInPrompt(id: 'emo-020', text: 'hurt', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-021', text: 'threatened', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-022', text: 'hateful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-023', text: 'mad', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-024', text: 'aggressive', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-025', text: 'frustrated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-026', text: 'distant', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-027', text: 'critical', category: PromptCategory.emotions),

  // Outer (14 unique — insecure deduped, already in Fear middle)
  BuiltInPrompt(id: 'emo-028', text: 'embarrassed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-029', text: 'devastated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-030', text: 'jealous', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-031', text: 'resentful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-032', text: 'violated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-033', text: 'furious', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-034', text: 'enraged', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-035', text: 'provoked', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-036', text: 'hostile', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-037', text: 'infuriated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-038', text: 'withdrawn', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-039', text: 'suspicious', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-040', text: 'skeptical', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-041', text: 'sarcastic', category: PromptCategory.emotions),

  // ── DISGUST ───────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-042', text: 'disgusted', category: PromptCategory.emotions),

  // Middle (4)
  BuiltInPrompt(id: 'emo-043', text: 'disapproval', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-044', text: 'disappointed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-045', text: 'awful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-046', text: 'avoidance', category: PromptCategory.emotions),

  // Outer (8)
  BuiltInPrompt(id: 'emo-047', text: 'judgmental', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-048', text: 'loathing', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-049', text: 'repugnant', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-050', text: 'revolted', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-051', text: 'revulsion', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-052', text: 'detestable', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-053', text: 'aversion', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-054', text: 'hesitant', category: PromptCategory.emotions),

  // ── SAD ───────────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-055', text: 'sad', category: PromptCategory.emotions),

  // Middle (6)
  BuiltInPrompt(id: 'emo-056', text: 'guilty', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-057', text: 'abandoned', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-058', text: 'despair', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-059', text: 'depressed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-060', text: 'lonely', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-061', text: 'bored', category: PromptCategory.emotions),

  // Outer (10 unique — inferior deduped to Fear outer; abandoned deduped to Sad middle)
  BuiltInPrompt(id: 'emo-062', text: 'remorseful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-063', text: 'ashamed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-064', text: 'ignored', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-065', text: 'victimized', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-066', text: 'powerless', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-067', text: 'vulnerable', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-068', text: 'empty', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-069', text: 'isolated', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-070', text: 'apathetic', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-071', text: 'indifferent', category: PromptCategory.emotions),

  // ── HAPPY ─────────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-072', text: 'happy', category: PromptCategory.emotions),

  // Middle (8)
  BuiltInPrompt(id: 'emo-073', text: 'joyful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-074', text: 'interested', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-075', text: 'proud', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-076', text: 'accepted', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-077', text: 'powerful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-078', text: 'peaceful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-079', text: 'optimistic', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-080', text: 'intimate', category: PromptCategory.emotions),

  // Outer (16)
  BuiltInPrompt(id: 'emo-081', text: 'inspired', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-082', text: 'open', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-083', text: 'playful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-084', text: 'sensitive', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-085', text: 'hopeful', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-086', text: 'loving', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-087', text: 'provocative', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-088', text: 'courageous', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-089', text: 'respected', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-090', text: 'fulfilled', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-091', text: 'important', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-092', text: 'confident', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-093', text: 'amused', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-094', text: 'inquisitive', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-095', text: 'ecstatic', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-096', text: 'liberated', category: PromptCategory.emotions),

  // ── SURPRISED ─────────────────────────────────────────────────────────────

  // Inner
  BuiltInPrompt(id: 'emo-097', text: 'surprised', category: PromptCategory.emotions),

  // Middle (4)
  BuiltInPrompt(id: 'emo-098', text: 'startled', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-099', text: 'confused', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-100', text: 'amazed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-101', text: 'excited', category: PromptCategory.emotions),

  // Outer (8)
  BuiltInPrompt(id: 'emo-102', text: 'energetic', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-103', text: 'eager', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-104', text: 'awe', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-105', text: 'astonished', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-106', text: 'perplexed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-107', text: 'disillusioned', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-108', text: 'dismayed', category: PromptCategory.emotions),
  BuiltInPrompt(id: 'emo-109', text: 'shocked', category: PromptCategory.emotions),
];
