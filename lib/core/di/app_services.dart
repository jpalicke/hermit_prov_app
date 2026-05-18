// ABOUTME: InheritedWidget that provides all repository instances to the widget tree.
// ABOUTME: Use AppServices.of(context) to obtain any repository from any widget.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:hermit_prov_app/domain/history/practice_history_repository.dart';
import 'package:hermit_prov_app/domain/journal/journal_repository.dart';
import 'package:hermit_prov_app/domain/prompts/prompt_repository.dart';
import 'package:hermit_prov_app/domain/drills/drill_settings_repository.dart';
import 'package:hermit_prov_app/domain/settings/app_preferences_repository.dart';
import 'package:hermit_prov_app/domain/tts/tts_service.dart';

class AppServices extends InheritedWidget {
  AppServices({
    super.key,
    required this.promptRepository,
    required this.drillSettingsRepository,
    required this.practiceHistoryRepository,
    required this.journalRepository,
    required this.appPreferencesRepository,
    required this.ttsService,
    ValueNotifier<ThemeMode>? themeNotifier,
    required super.child,
  }) : themeNotifier = themeNotifier ?? ValueNotifier(ThemeMode.system);

  /// Creates an [AppServices] wired with all in-memory repository implementations.
  factory AppServices.withInMemory({Key? key, required Widget child}) {
    return AppServices(
      key: key,
      promptRepository: InMemoryPromptRepository(),
      drillSettingsRepository: InMemoryDrillSettingsRepository(),
      practiceHistoryRepository: InMemoryPracticeHistoryRepository(),
      journalRepository: InMemoryJournalRepository(),
      appPreferencesRepository: InMemoryAppPreferencesRepository(),
      ttsService: FakeTtsService(),
      child: child,
    );
  }

  /// Creates an [AppServices] wired with persistent on-device storage.
  /// Uses Drift/SQLite for structured data and SharedPreferences for app settings.
  static Future<AppServices> withLocalStorage({
    Key? key,
    required Widget child,
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
      child: child,
    );
  }

  final PromptRepository promptRepository;
  final DrillSettingsRepository drillSettingsRepository;
  final PracticeHistoryRepository practiceHistoryRepository;
  final JournalRepository journalRepository;
  final AppPreferencesRepository appPreferencesRepository;
  final TtsService ttsService;

  /// Notifier for the current theme mode. Update this to trigger a live theme change.
  final ValueNotifier<ThemeMode> themeNotifier;

  /// Retrieves the nearest [AppServices] from the widget tree.
  /// Throws if no [AppServices] ancestor is found.
  static AppServices of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(result != null, 'No AppServices found in context');
    return result!;
  }

  /// The repository references held by this widget never change after
  /// construction, so the tree never needs to rebuild when data inside
  /// a repository changes.
  @override
  bool updateShouldNotify(AppServices oldWidget) => false;
}
