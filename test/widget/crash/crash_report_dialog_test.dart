// ABOUTME: Widget tests for CrashReportDialog verifying buttons, privacy text, and service interaction.
// ABOUTME: Uses a recording in-memory CrashReportService to verify send behavior without mocks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/domain/crash/crash_report.dart';
import 'package:hermit_prov_app/domain/crash/crash_report_service.dart';
import 'package:hermit_prov_app/features/crash/crash_report_dialog.dart';

/// In-memory recording implementation — no mock frameworks.
class _RecordingCrashReportService implements CrashReportService {
  final List<CrashReport> sentReports = [];

  @override
  Future<void> sendReport(CrashReport report) async {
    sentReports.add(report);
  }
}

const _testReport = CrashReport(
  errorSummary: 'Test error',
  stackTrace: '#0 main (main.dart:1)',
  appVersion: '1.0.0',
  deviceOs: 'iOS 17',
);

Widget _wrapWithDialog(CrashReportService service) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () => CrashReportDialog.show(context, _testReport, service),
          child: const Text('Show Dialog'),
        ),
      ),
    ),
  );
}

void main() {
  group('CrashReportDialog', () {
    testWidgets('dialog shows "Send Report" and "Don\'t Send" buttons',
        (tester) async {
      final service = _RecordingCrashReportService();
      await tester.pumpWidget(_wrapWithDialog(service));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Send Report'), findsOneWidget);
      expect(find.text("Don't Send"), findsOneWidget);
    });

    testWidgets('dialog shows the privacy note text', (tester) async {
      final service = _RecordingCrashReportService();
      await tester.pumpWidget(_wrapWithDialog(service));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('not your custom prompts or journal entries'),
        findsOneWidget,
      );
    });

    testWidgets('"Don\'t Send" closes without calling service', (tester) async {
      final service = _RecordingCrashReportService();
      await tester.pumpWidget(_wrapWithDialog(service));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Don't Send"));
      await tester.pumpAndSettle();

      expect(service.sentReports, isEmpty);
      expect(find.text('Send Report'), findsNothing);
    });

    testWidgets('"Send Report" calls service.sendReport', (tester) async {
      final service = _RecordingCrashReportService();
      await tester.pumpWidget(_wrapWithDialog(service));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Report'));
      await tester.pumpAndSettle();

      expect(service.sentReports, hasLength(1));
      expect(service.sentReports.first.errorSummary, 'Test error');
    });
  });
}
