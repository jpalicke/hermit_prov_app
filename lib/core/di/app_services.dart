// ABOUTME: InheritedWidget that provides all repository instances to the widget tree.
// ABOUTME: Use AppServices.of(context) to obtain any repository from any widget.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/data/crash/no_op_crash_report_service.dart';
import 'package:hermit_prov_app/data/local/database_opener.dart';
import 'package:hermit_prov_app/data/repositories/drift_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/drift_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/drift_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/drift_prompt_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_drill_settings_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_journal_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_practice_history_repository.dart';
import 'package:hermit_prov_app/data/repositories/in_memory_prompt_repository.dart';
import 'package:hermit_prov_app/data/repositories/shared_preferences_app_preferences_repository.dart';
import 'package:hermit_prov_app/data/seed/seed_prompts.dart';
import 'package:hermit_prov_app/data/tts/fake_tts_service.dart';
import 'package:hermit_prov_app/data/tts/flutter_tts_service.dart';
import 'package:hermit_prov_app/domain/crash/crash_report_service.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppServices extends InheritedWidget {
  AppServices({
    required this.promptRepository,
    required this.drillSettingsRepository,
    required this.practiceHistoryRepository,
    required this.journalRepository,
    required this.appPreferencesRepository,
    required this.ttsService,
    required this.crashReportService,
    this.notifyDependents = false,
    required super.child,
    super.key,
    ValueNotifier<ThemeMode>? themeNotifier,
  }) : themeNotifier = themeNotifier ?? ValueNotifier(ThemeMode.system);

  /// Creates an [AppServices] wired with all in-memory repository implementations.
  factory AppServices.withInMemory({required Widget child, Key? key}) {
    return AppServices(
      key: key,
      promptRepository: InMemoryPromptRepository(),
      drillSettingsRepository: InMemoryDrillSettingsRepository(),
      practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
      journalRepository: InMemoryJournalRepository(),
      appPreferencesRepository: InMemoryAppPreferencesRepository(),
      ttsService: FakeTtsService(),
      crashReportService: const NoOpCrashReportService(),
      child: child,
    );
  }

  /// Creates an [AppServices] wired with persistent on-device storage.
  /// Uses Drift/SQLite for structured data and SharedPreferences for app settings.
  static Future<AppServices> withLocalStorage({
    required Widget child,
    Key? key,
  }) async {
    final db = openAppDatabase();
    final prefs = await SharedPreferences.getInstance();
    final prefsRepo = SharedPreferencesAppPreferencesRepository(prefs);
    return AppServices(
      key: key,
      promptRepository: DriftPromptRepository(db, builtIns: buildSeedPrompts()),
      drillSettingsRepository: DriftDrillSettingsRepository(db),
      practiceHistoryRepository: DriftPracticeHistoryRepository(db),
      journalRepository: DriftJournalRepository(db),
      appPreferencesRepository: prefsRepo,
      ttsService: FlutterTtsService(
        preferencesRepository: prefsRepo,
        enabled: true,
      ),
      crashReportService: const NoOpCrashReportService(),
      child: child,
    );
  }

  final PromptRepository promptRepository;
  final DrillSettingsRepository drillSettingsRepository;
  final PracticeHistoryRepository practiceHistoryRepository;
  final JournalRepository journalRepository;
  final AppPreferencesRepository appPreferencesRepository;
  final TtsService ttsService;
  final CrashReportService crashReportService;

  /// Notifier for the current theme mode. Update this to trigger a live theme change.
  final ValueNotifier<ThemeMode> themeNotifier;

  /// When true, forces all dependent widgets to rebuild and receive a
  /// didChangeDependencies call on the next pump. Intended for use in widget
  /// tests that need to exercise initialization guards in StatefulWidgets
  /// that depend on AppServices. Leave false (the default) in production use.
  final bool notifyDependents;

  /// Retrieves the nearest [AppServices] from the widget tree.
  /// Throws if no [AppServices] ancestor is found.
  static AppServices of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(result != null, 'No AppServices found in context');
    return result!;
  }

  /// Repository references never change after construction, so dependents do
  /// not need to rebuild on a normal update. The notifyDependents flag can be
  /// set to true in widget tests to exercise didChangeDependencies guard logic.
  @override
  bool updateShouldNotify(AppServices oldWidget) => notifyDependents;
}
