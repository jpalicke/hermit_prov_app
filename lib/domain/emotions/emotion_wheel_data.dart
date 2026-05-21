// ABOUTME: Domain model for the Emotion Wheel feature.
// ABOUTME: Contains EmotionEntry, EmotionMid, EmotionCore, kEmotionWheel data, and buildFlatEmotionList.

// Source: Glenn Trigg Emotions Wheel (CC BY 4.0)
// https://glenntrigg.net/emotions-wheel/
import 'package:flutter/material.dart';

class EmotionEntry {
  const EmotionEntry({
    required this.word,
    required this.ring,
    required this.category,
    required this.color,
  });

  final String word;
  final String ring; // 'core', 'mid', 'outer'
  final String category;
  final Color color;
}

class EmotionMid {
  const EmotionMid({required this.name, required this.outer});

  final String name;
  final List<String> outer;
}

class EmotionCore {
  const EmotionCore({required this.core, required this.color, required this.mid});

  final String core;
  final Color color;
  final List<EmotionMid> mid;
}

// Clockwise from top, matching the Trigg wheel layout
const List<EmotionCore> kEmotionWheel = [
  EmotionCore(core: 'Anger', color: Color(0xFFCC8080), mid: [
    EmotionMid(name: 'Mad', outer: ['Humiliated', 'Threatened']),
    EmotionMid(name: 'Aggressive', outer: ['Hateful', 'Hurt']),
    EmotionMid(name: 'Hostile', outer: ['Infuriated', 'Irritated']),
    EmotionMid(name: 'Frustrated', outer: ['Provoked', 'Enraged', 'Furious', 'Violated', 'Resentful']),
  ]),
  EmotionCore(core: 'Disgust', color: Color(0xFF9878C0), mid: [
    EmotionMid(name: 'Distant', outer: ['Withdrawn', 'Suspicious']),
    EmotionMid(name: 'Critical', outer: ['Skeptical', 'Sarcastic']),
    EmotionMid(name: 'Disapproval', outer: ['Judgmental', 'Loathing']),
    EmotionMid(name: 'Awful', outer: ['Repugnant', 'Revolted', 'Revulsion']),
    EmotionMid(name: 'Avoidance', outer: ['Detestable', 'Aversion', 'Hesitant']),
  ]),
  EmotionCore(core: 'Sad', color: Color(0xFF7888C0), mid: [
    EmotionMid(name: 'Guilty', outer: ['Remorseful', 'Ashamed']),
    EmotionMid(name: 'Abandoned', outer: ['Ignored', 'Victimized', 'Powerless', 'Vulnerable']),
    EmotionMid(name: 'Despair', outer: ['Inferior', 'Empty']),
    EmotionMid(name: 'Depressed', outer: ['Indifferent']),
    EmotionMid(name: 'Lonely', outer: ['Isolated']),
    EmotionMid(name: 'Bored', outer: ['Apathetic']),
  ]),
  EmotionCore(core: 'Happy', color: Color(0xFFCCB840), mid: [
    EmotionMid(name: 'Joyful', outer: ['Inquisitive', 'Amused', 'Eager']),
    EmotionMid(name: 'Interested', outer: ['Important', 'Fulfilled']),
    EmotionMid(name: 'Proud', outer: ['Confident', 'Respected']),
    EmotionMid(name: 'Accepted', outer: ['Loving', 'Hopeful']),
    EmotionMid(name: 'Powerful', outer: ['Courageous', 'Inspired']),
    EmotionMid(name: 'Peaceful', outer: ['Provocative', 'Sensitive']),
    EmotionMid(name: 'Optimistic', outer: ['Eager']),
    EmotionMid(name: 'Intimate', outer: ['Playful']),
  ]),
  EmotionCore(core: 'Surprise', color: Color(0xFF88C068), mid: [
    EmotionMid(name: 'Startled', outer: ['Shocked', 'Dismayed']),
    EmotionMid(name: 'Confused', outer: ['Disillusioned', 'Perplexed']),
    EmotionMid(name: 'Amazed', outer: ['Astonished', 'Awe']),
    EmotionMid(name: 'Excited', outer: ['Energetic', 'Liberated', 'Ecstatic']),
  ]),
  EmotionCore(core: 'Fear', color: Color(0xFF6090A8), mid: [
    EmotionMid(name: 'Scared', outer: ['Terrified', 'Frightened']),
    EmotionMid(name: 'Anxious', outer: ['Overwhelmed', 'Worried']),
    EmotionMid(name: 'Insecure', outer: ['Inadequate', 'Worthless', 'Insignificant']),
    EmotionMid(name: 'Rejected', outer: ['Disrespected', 'Alienated', 'Embarrassed', 'Ridiculed', 'Jealous', 'Devastated']),
  ]),
];

List<EmotionEntry> buildFlatEmotionList() {
  final result = <EmotionEntry>[];
  for (final e in kEmotionWheel) {
    result.add(EmotionEntry(word: e.core, ring: 'core', category: e.core, color: e.color));
    for (final m in e.mid) {
      result.add(EmotionEntry(word: m.name, ring: 'mid', category: e.core, color: e.color));
      for (final o in m.outer) {
        result.add(EmotionEntry(word: o, ring: 'outer', category: e.core, color: e.color));
      }
    }
  }
  return result;
}
