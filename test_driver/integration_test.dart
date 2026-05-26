// ABOUTME: Standard flutter drive integration test driver shim.
// ABOUTME: Required by flutter drive to proxy between the test and the running app.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
