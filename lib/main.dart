// ABOUTME: Entry point for the Hermit Prov app.
// ABOUTME: Initializes local storage, mounts AppServices, and wires crash handlers.

import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/crash/crash_payload_sanitizer.dart';
import 'package:hermit_prov_app/features/crash/crash_report_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _handleCrash(details.exception, details.stack ?? StackTrace.empty);
  };

  // Web uses in-memory storage — SQLite/driftDatabase requires native setup.
  final app = kIsWeb
      ? AppServices.withInMemory(child: const HermitProvApp())
      : await AppServices.withLocalStorage(child: const HermitProvApp());

  runZonedGuarded(
    () => runApp(app),
    _handleCrash,
  );
}

void _handleCrash(Object error, StackTrace stack) {
  final context = appNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;

  final services = AppServices.of(context);
  final report = const CrashPayloadSanitizer().sanitize(
    errorSummary: error.toString(),
    stackTrace: stack.toString(),
    appVersion: '1.0.0',
    deviceOs: defaultTargetPlatform.name,
  );
  CrashReportDialog.show(context, report, services.crashReportService);
}
