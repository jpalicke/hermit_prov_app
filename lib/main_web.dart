// ABOUTME: Entry point for the tools-only web build of Hermit Prov.
// ABOUTME: Run with: flutter build web --target lib/main_web.dart

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/web/web_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HermitProvWebApp());
}
