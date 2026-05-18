// ABOUTME: Entry point for the Hermit-Prov app.
// ABOUTME: Initializes local storage and mounts AppServices before running the app.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    await AppServices.withLocalStorage(
      child: const HermitProvApp(),
    ),
  );
}
