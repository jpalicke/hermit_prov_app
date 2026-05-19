// ABOUTME: Emotion Wheel screen allowing users to browse and select emotions by tapping segments.
// ABOUTME: Features an interactive zoomable wheel, selected emotion display card, and random picker with ring filter.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/emotions/emotion_wheel_data.dart';

// ── Segment model ─────────────────────────────────────────────────────────────

class _Segment {
  final EmotionEntry emotion;
  final double r1, r2; // as fractions of outerRadius
  final double startDeg, endDeg; // degrees from north (top), clockwise
  final Color fillColor;

  const _Segment({
    required this.emotion,
    required this.r1,
    required this.r2,
    required this.startDeg,
    required this.endDeg,
    required this.fillColor,
  });

  bool contains(Offset center, double outerRadius, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final r = sqrt(dx * dx + dy * dy) / outerRadius;
    if (r < r1 - 0.01 || r > r2 + 0.01) return false;
    // Convert to degrees-from-north, clockwise
    final angle = (atan2(dx, -dy) * 180 / pi + 360) % 360;
    if (startDeg < endDeg) return angle >= startDeg && angle < endDeg;
    return angle >= startDeg || angle < endDeg; // wrap-around case
  }
}

// ── Segment builder ───────────────────────────────────────────────────────────

Color _lighten(Color color, int amount) => Color.fromARGB(
      (color.a * 255).round().clamp(0, 255),
      ((color.r * 255).round() + amount).clamp(0, 255),
      ((color.g * 255).round() + amount).clamp(0, 255),
      ((color.b * 255).round() + amount).clamp(0, 255),
    );

List<_Segment> _buildSegments() {
  int totalOuter = 0;
  for (final e in kEmotionWheel) {
    for (final m in e.mid) {
      totalOuter += m.outer.length;
    }
  }

  final result = <_Segment>[];
  double currentAngle = 0;

  for (final e in kEmotionWheel) {
    final emotionOuterCount = e.mid.fold<int>(0, (a, m) => a + m.outer.length);
    final emotionAngle = (emotionOuterCount / totalOuter) * 360;

    result.add(_Segment(
      emotion: EmotionEntry(word: e.core, ring: 'core', category: e.core, color: e.color),
      r1: 0, r2: 95 / 250,
      startDeg: currentAngle,
      endDeg: currentAngle + emotionAngle,
      fillColor: e.color,
    ));

    double midAngle = currentAngle;
    for (final m in e.mid) {
      final midSpan = (m.outer.length / totalOuter) * 360;
      result.add(_Segment(
        emotion: EmotionEntry(word: m.name, ring: 'mid', category: e.core, color: e.color),
        r1: 95 / 250, r2: 160 / 250,
        startDeg: midAngle,
        endDeg: midAngle + midSpan,
        fillColor: _lighten(e.color, 30),
      ));

      double outerAngle = midAngle;
      final outerSpan = 360.0 / totalOuter;
      for (final o in m.outer) {
        result.add(_Segment(
          emotion: EmotionEntry(word: o, ring: 'outer', category: e.core, color: e.color),
          r1: 160 / 250, r2: 1.0,
          startDeg: outerAngle,
          endDeg: outerAngle + outerSpan,
          fillColor: _lighten(e.color, 60),
        ));
        outerAngle += outerSpan;
      }
      midAngle += midSpan;
    }
    currentAngle += emotionAngle;
  }
  return result;
}

// Computed once per state lifecycle to survive hot reload.
final _kFlatEmotions = buildFlatEmotionList();

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<_Segment> segments;
  final EmotionEntry? selected;
  final Offset center;
  final double outerRadius;

  _WheelPainter({
    required this.segments,
    required this.selected,
    required this.center,
    required this.outerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF111111)
      ..strokeWidth = 0.8;

    for (final seg in segments) {
      final isSelected = selected != null &&
          selected!.word == seg.emotion.word &&
          selected!.ring == seg.emotion.ring;
      fill.color = isSelected ? Colors.white : seg.fillColor;
      final path = _segPath(seg);
      canvas.drawPath(path, fill);
      // Don't stroke core segments — the convergence at center creates a dark blob.
      // Draw radial boundary lines instead (see below).
      if (seg.emotion.ring != 'core') canvas.drawPath(path, stroke);
    }

    // Radial boundary lines for core segments
    for (final seg in segments.where((s) => s.emotion.ring == 'core')) {
      final startRad = (seg.startDeg - 90) * pi / 180;
      final r2 = seg.r2 * outerRadius;
      canvas.drawLine(
        center,
        Offset(center.dx + r2 * cos(startRad), center.dy + r2 * sin(startRad)),
        stroke,
      );
    }

    // Core ring labels
    final coreR = outerRadius * (50 / 250);
    for (final seg in segments.where((s) => s.emotion.ring == 'core')) {
      final midDeg = (seg.startDeg + seg.endDeg) / 2;
      final isSelected = selected?.word == seg.emotion.word && selected?.ring == 'core';
      _drawLabel(
        canvas, seg.emotion.word, coreR, midDeg,
        outerRadius * 0.052,
        isSelected ? seg.emotion.color : const Color(0xFF111111),
        bold: true,
      );
    }

    // Mid ring labels
    final midR = outerRadius * ((95 + 160) / 2 / 250);
    for (final seg in segments.where((s) => s.emotion.ring == 'mid')) {
      final midDeg = (seg.startDeg + seg.endDeg) / 2;
      final isSelected = selected?.word == seg.emotion.word && selected?.ring == 'mid';
      _drawLabel(
        canvas, seg.emotion.word, midR, midDeg,
        outerRadius * 0.048,
        isSelected ? seg.emotion.color : const Color(0xFF111111),
      );
    }

    // Outer ring labels
    final outerR = outerRadius * ((160 + 250) / 2 / 250);
    for (final seg in segments.where((s) => s.emotion.ring == 'outer')) {
      final midDeg = (seg.startDeg + seg.endDeg) / 2;
      final isSelected = selected?.word == seg.emotion.word && selected?.ring == 'outer';
      _drawLabel(
        canvas, seg.emotion.word, outerR, midDeg,
        outerRadius * 0.038,
        isSelected ? seg.emotion.color : const Color(0xFF111111),
      );
    }
  }

  Path _segPath(_Segment seg) {
    final r1 = seg.r1 * outerRadius;
    final r2 = seg.r2 * outerRadius;
    final startRad = (seg.startDeg - 90) * pi / 180;
    final sweepRad = (seg.endDeg - seg.startDeg) * pi / 180;
    if (r1 == 0) {
      // Pie slice from center
      return Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + r2 * cos(startRad), center.dy + r2 * sin(startRad))
        ..arcTo(Rect.fromCircle(center: center, radius: r2), startRad, sweepRad, false)
        ..close();
    }
    return Path()
      ..moveTo(center.dx + r1 * cos(startRad), center.dy + r1 * sin(startRad))
      ..arcTo(Rect.fromCircle(center: center, radius: r1), startRad, sweepRad, false)
      ..lineTo(center.dx + r2 * cos(startRad + sweepRad), center.dy + r2 * sin(startRad + sweepRad))
      ..arcTo(Rect.fromCircle(center: center, radius: r2), startRad + sweepRad, -sweepRad, false)
      ..close();
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    double r,
    double midDeg,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final midRad = (midDeg - 90) * pi / 180;
    final pos = Offset(center.dx + r * cos(midRad), center.dy + r * sin(midRad));

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    var rotate = midRad;
    if (midDeg > 180) rotate += pi;
    canvas.rotate(rotate);
    canvas.translate(-tp.width / 2, -tp.height / 2);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.selected?.word != selected?.word ||
      old.selected?.ring != selected?.ring ||
      old.outerRadius != outerRadius;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EmotionWheelScreen extends StatefulWidget {
  const EmotionWheelScreen({super.key});

  @override
  State<EmotionWheelScreen> createState() => _EmotionWheelScreenState();
}

class _EmotionWheelScreenState extends State<EmotionWheelScreen> {
  late final List<_Segment> _segments;
  EmotionEntry? _selected;
  String _filter = 'all'; // all | core | mid | outer

  @override
  void initState() {
    super.initState();
    _segments = _buildSegments();
  }

  static const _filterLabels = {
    'all': 'Any',
    'core': 'Core only',
    'mid': 'Feelings',
    'outer': 'Nuanced',
  };

  void _select(EmotionEntry entry) {
    setState(() => _selected = entry);
  }

  void _pickRandom() {
    final pool = _filter == 'all'
        ? _kFlatEmotions
        : _kFlatEmotions.where((e) => e.ring == _filter).toList();
    if (pool.isEmpty) return;
    final rand = pool[Random().nextInt(pool.length)];
    _select(rand);
  }

  void _onWheelTap(Offset position, Offset center, double outerRadius) {
    for (final seg in _segments.reversed) {
      if (seg.contains(center, outerRadius, position)) {
        _select(seg.emotion);
        return;
      }
    }
  }

  String _ringLabel(String ring) => switch (ring) {
        'core' => 'Core Emotion',
        'mid' => 'Feeling',
        _ => 'Nuance',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Wheel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wheel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final side = constraints.maxWidth;
                  final center = Offset(side / 2, side / 2);
                  final outerRadius = side / 2 * 0.93;
                  return Container(
                    width: side,
                    height: side,
                    color: cs.surfaceContainerLowest,
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 5.0,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: Semantics(
                        button: true,
                        label: _selected != null
                            ? 'Emotion wheel. Selected: ${_selected!.word}. Tap to select a different emotion.'
                            : 'Emotion wheel. Tap a segment to select an emotion.',
                        onTap: () {},
                        child: GestureDetector(
                          onTapUp: (d) => _onWheelTap(d.localPosition, center, outerRadius),
                          child: CustomPaint(
                            size: Size(side, side),
                            painter: _WheelPainter(
                              segments: _segments,
                              selected: _selected,
                              center: center,
                              outerRadius: outerRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Selected emotion display card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
                liveRegion: true,
                label: _selected != null
                    ? 'Selected emotion: ${_selected!.word}. ${_ringLabel(_selected!.ring)} in category ${_selected!.category}.'
                    : 'No emotion selected.',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selected != null
                        ? _selected!.color.withValues(alpha: 0.12)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selected != null
                          ? _selected!.color.withValues(alpha: 0.4)
                          : cs.outline,
                    ),
                  ),
                  child: _selected != null
                      ? ExcludeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_ringLabel(_selected!.ring)} · ${_selected!.category}'.toUpperCase(),
                                style: TextStyle(
                                  color: _selected!.color,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selected!.word,
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Semantics(
                                button: true,
                                label: 'Clear selected emotion',
                                child: GestureDetector(
                                  onTap: () => setState(() => _selected = null),
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.3),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'tap any segment to select an emotion',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.4),
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Random picker panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RANDOM',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.45),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterLabels.entries.map((e) {
                        final active = _filter == e.key;
                        return FilterChip(
                          label: Text(e.value),
                          selected: active,
                          onSelected: (_) => setState(() => _filter = e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Tooltip(
                        message: 'Pick a random emotion from the selected ring filter',
                        child: FilledButton(
                          onPressed: _pickRandom,
                          child: const Text('Pick random emotion'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
