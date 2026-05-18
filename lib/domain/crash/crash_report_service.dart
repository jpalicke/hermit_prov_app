// ABOUTME: Abstract interface for sending crash reports.
// ABOUTME: Implementations decide where/how to deliver the report.

import 'package:hermit_prov_app/domain/crash/crash_report.dart';

abstract interface class CrashReportService {
  Future<void> sendReport(CrashReport report);
}
