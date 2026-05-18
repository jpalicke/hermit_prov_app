// ABOUTME: Domain model for a single segment in a drill session (e.g. speaking, regroup).
// ABOUTME: Carries an id, type, duration, optional prompt payload, and optional display label.

/// Classification of what a drill segment represents.
enum DrillSegmentType {
  /// The performer actively speaks / performs.
  speaking,

  /// A brief regroup or transition period between reps.
  regroup,

  /// A timed interval for any other purpose (e.g. character creation pass).
  timed,
}

/// An immutable description of one segment in a drill session.
class DrillSegment {
  const DrillSegment({
    required this.id,
    required this.type,
    required this.duration,
    this.promptPayload,
    this.label,
  }) : assert(id.length > 0, 'id must not be empty');

  /// Stable identifier within the sequence (e.g. "speaking_0", "regroup_0").
  final String id;

  final DrillSegmentType type;

  /// How long this segment lasts.
  final Duration duration;

  /// Optional prompt text assigned to this segment.
  final String? promptPayload;

  /// Optional human-readable label shown in the session UI.
  final String? label;

  DrillSegment copyWith({
    String? id,
    DrillSegmentType? type,
    Duration? duration,
    String? promptPayload,
    String? label,
  }) {
    return DrillSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      promptPayload: promptPayload ?? this.promptPayload,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrillSegment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          duration == other.duration &&
          promptPayload == other.promptPayload &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, type, duration, promptPayload, label);

  @override
  String toString() =>
      'DrillSegment(id: $id, type: $type, duration: $duration, '
      'label: $label, prompt: $promptPayload)';
}
