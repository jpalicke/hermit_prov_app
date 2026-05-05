// ABOUTME: InheritedWidget that provides all repository instances to the widget tree.
// ABOUTME: Use AppServices.of(context) to obtain any repository from any widget.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';

class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.promptRepository,
    required this.drillSettingsRepository,
    required this.practiceHistoryRepository,
    required this.journalRepository,
    required this.appPreferencesRepository,
    required super.child,
  });

  /// Creates an [AppServices] wired with all in-memory repository implementations.
  factory AppServices.withInMemory({Key? key, required Widget child}) {
    return AppServices(
      key: key,
      promptRepository: InMemoryPromptRepository(),
      drillSettingsRepository: InMemoryDrillSettingsRepository(),
      practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
      journalRepository: InMemoryJournalRepository(),
      appPreferencesRepository: InMemoryAppPreferencesRepository(),
      child: child,
    );
  }

  final PromptRepository promptRepository;
  final DrillSettingsRepository drillSettingsRepository;
  final PracticeHistoryRepository practiceHistoryRepository;
  final JournalRepository journalRepository;
  final AppPreferencesRepository appPreferencesRepository;

  /// Retrieves the nearest [AppServices] from the widget tree.
  /// Throws if no [AppServices] ancestor is found.
  static AppServices of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(result != null, 'No AppServices found in context');
    return result!;
  }

  /// Repositories are immutable value objects; the tree never needs to rebuild
  /// due to a settings change inside a repository.
  @override
  bool updateShouldNotify(AppServices oldWidget) => false;
}
