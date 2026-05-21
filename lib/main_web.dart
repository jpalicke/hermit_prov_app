// ABOUTME: Entry point for the tools-only web build of Hermit Prov.
// ABOUTME: Run with: flutter build web --target lib/main_web.dart

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/web/web_app.dart';

// Note: main.dart wraps runApp with runZonedGuarded and FlutterError.onError
// for crash handling. This entry point omits both intentionally: the web build
// has no crash-reporting target and runs in a browser sandbox.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HermitProvWebApp());
}
