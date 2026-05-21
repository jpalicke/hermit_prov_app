// ABOUTME: History tab screen showing practice stats, per-drill breakdown, and recent sessions.
// ABOUTME: Loads data from PracticeHistoryRepository via AppServices; shows empty state when no sessions.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/drills/drill_id.dart';
import 'package:hermit_prov_app/domain/history/practice_session.dart';
import 'package:hermit_prov_app/domain/history/practice_stats.dart';
import 'package:hermit_prov_app/features/journal/journal_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PracticeSession>? _sessions;
  bool _loading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // AppServices may not be present during certain tests; guard gracefully.
    final appServices =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    if (appServices == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final sessions =
        await appServices.practiceHistoryRepository.getRecentSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sessions = _sessions ?? [];
    final stats = PracticeStats.compute(sessions);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(
                'History',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              backgroundColor: cs.surface,
              surfaceTintColor: Colors.transparent,
            ),
            // ── Journal entry point ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _JournalCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const JournalScreen(),
                    ),
                  ),
                ),
              ),
            ),
            if (sessions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No sessions yet. Complete a drill for at least 30 seconds to start tracking.',
                      textAlign: TextAlign.center,
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              // ── Stats cards ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _StatsGrid(stats: stats),
                ),
              ),
              // ── By Drill breakdown ─────────────────────────────────────────
              if (stats.sessionsByDrill.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'By Drill',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _DrillBreakdown(stats: stats),
                  ),
                ),
              ],
              // ── Recent Sessions header ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent Sessions',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
              // ── Session list ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _SessionTile(session: sessions[index]),
                    childCount: sessions.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: [
        _StatCard(
          label: 'Total Time',
          value: _formatDuration(stats.totalTime),
        ),
        _StatCard(
          label: 'Sessions',
          value: '${stats.sessionsCompleted}',
        ),
        _StatCard(
          label: 'Current Streak',
          value: '${stats.currentStreak} days',
        ),
        _StatCard(
          label: 'Longest Streak',
          value: '${stats.longestStreak} days',
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      label: '$label: $value',
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DrillBreakdown extends StatelessWidget {
  const _DrillBreakdown({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final drills = DrillId.values
        .where(stats.sessionsByDrill.containsKey)
        .toList();

    return Card(
      color: cs.surfaceContainerLow,
      child: Column(
        children: drills.map((drillId) {
          final count = stats.sessionsByDrill[drillId] ?? 0;
          final time = stats.timeByDrill[drillId] ?? Duration.zero;
          final isLast = drillId == drills.last;

          return Column(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  drillId.displayName,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                trailing: Text(
                  '$count session${count == 1 ? '' : 's'}  ${_formatDuration(time)}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: cs.outlineVariant,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      label: '${session.drillId.displayName}, ${_formatDate(session.loggedAt)}, duration: ${_formatSessionDuration(session.duration)}',
      child: ExcludeSemantics(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          title: Text(
            session.drillId.displayName,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            _formatDate(session.loggedAt),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Text(
            _formatSessionDuration(session.duration),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  /// Formats the date as e.g. "May 18".
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = dt.toLocal();
    return '${months[local.month - 1]} ${local.day}';
  }

  /// Formats duration as e.g. "4m 30s".
  String _formatSessionDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: cs.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: 'Open Journal',
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                ExcludeSemantics(child: Icon(Icons.book_outlined, color: cs.primary)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Journal',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                ExcludeSemantics(child: Icon(Icons.chevron_right, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
