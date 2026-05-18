// ABOUTME: No-op implementation of CrashReportService used as a placeholder.
// ABOUTME: Does nothing — replace with a real provider when crash reporting is configured.

import 'package:hermit_prov_app/domain/crash/crash_report.dart';
import 'package:hermit_prov_app/domain/crash/crash_report_service.dart';

class NoOpCrashReportService implements CrashReportService {
  const NoOpCrashReportService();

  @override
  Future<void> sendReport(CrashReport report) async {
    // Intentionally does nothing. Replace with a real implementation when ready.
  }
}
