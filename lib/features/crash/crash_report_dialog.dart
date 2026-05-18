// ABOUTME: Dialog that prompts the user to send a crash report after an unexpected error.
// ABOUTME: Navigates to PrivacyAboutScreen when the user wants to review data practices.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/domain/crash/crash_report.dart';
import 'package:hermit_prov_app/domain/crash/crash_report_service.dart';
import 'package:hermit_prov_app/features/settings/privacy_about_screen.dart';

class CrashReportDialog {
  const CrashReportDialog._();

  static Future<void> show(
    BuildContext context,
    CrashReport report,
    CrashReportService service,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _CrashReportDialogContent(
        report: report,
        service: service,
      ),
    );
  }
}

class _CrashReportDialogContent extends StatelessWidget {
  const _CrashReportDialogContent({
    required this.report,
    required this.service,
  });

  final CrashReport report;
  final CrashReportService service;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Something went wrong'),
      content: const Text(
        'An unexpected error occurred. Would you like to send a report to help fix it?\n\n'
        'Includes technical crash details and app state, but not your custom prompts or journal entries.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyAboutScreen(),
              ),
            );
          },
          child: const Text('Privacy and About'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Don't Send"),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await service.sendReport(report);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report sent. Thank you.')),
              );
            }
          },
          child: const Text('Send Report'),
        ),
      ],
    );
  }
}
