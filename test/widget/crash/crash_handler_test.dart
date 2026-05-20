// ABOUTME: Integration test verifying the crash handler plumbing works end-to-end.
// ABOUTME: Confirms appNavigatorKey is live and can surface CrashReportDialog from app context.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';
import 'package:hermit_prov_app/domain/crash/crash_payload_sanitizer.dart';
import 'package:hermit_prov_app/features/crash/crash_report_dialog.dart';

const _testError = 'Forced test exception';

void main() {
  group('crash handler', () {
    testWidgets('appNavigatorKey has a live context after app launches',
        (tester) async {
      await tester.pumpWidget(
        AppServices.withInMemory(child: const HermitProvApp()),
      );
      await tester.pump();

      expect(appNavigatorKey.currentContext, isNotNull);
    });

    testWidgets(
        'crash dialog appears when shown via appNavigatorKey context',
        (tester) async {
      await tester.pumpWidget(
        AppServices.withInMemory(child: const HermitProvApp()),
      );
      await tester.pump();

      final context = appNavigatorKey.currentContext!;
      final services = AppServices.of(context);
      final report = const CrashPayloadSanitizer().sanitize(
        errorSummary: _testError,
        stackTrace: StackTrace.current.toString(),
        appVersion: '1.0.0',
        deviceOs: 'test',
      );

      // Don't await — showDialog resolves only when dismissed; we just need it open.
      unawaited(CrashReportDialog.show(context, report, services.crashReportService));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Send Report'), findsOneWidget);
    });
  });
}
