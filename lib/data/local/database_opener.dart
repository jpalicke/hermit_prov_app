// ABOUTME: Creates the AppDatabase instance for production use.
// ABOUTME: Uses drift_flutter's driftDatabase for cross-platform SQLite support.

import 'package:drift_flutter/drift_flutter.dart';
import 'app_database.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(driftDatabase(name: 'hermit_prov'));
}
