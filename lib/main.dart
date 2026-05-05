// ABOUTME: Entry point for the Hermit-Prov app.
// ABOUTME: Mounts AppServices with in-memory repositories, then runs HermitProvApp.

import 'package:flutter/material.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/core/di/app_services.dart';

void main() {
  runApp(
    AppServices.withInMemory(
      child: const HermitProvApp(),
    ),
  );
}
