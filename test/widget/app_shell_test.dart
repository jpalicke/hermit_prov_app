// ABOUTME: Widget tests for the app shell and bottom navigation.
// ABOUTME: Verifies app launches, navigation tabs are present, and Practice is the initial tab.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermit_prov_app/app.dart';
import 'package:hermit_prov_app/ui/navigation/bottom_nav_shell.dart';

void main() {
  group('App shell', () {
    testWidgets('app launches', (WidgetTester tester) async {
      await tester.pumpWidget(const HermitProvApp());
      expect(find.byType(BottomNavShell), findsOneWidget);
    });

    testWidgets('bottom navigation contains Practice, History, and Settings',
        (WidgetTester tester) async {
      await tester.pumpWidget(const HermitProvApp());

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      final nav = find.byType(BottomNavigationBar);
      expect(
        find.descendant(of: nav, matching: find.text('Practice')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('History')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Settings')),
        findsOneWidget,
      );
    });

    testWidgets('Practice is the initial tab', (WidgetTester tester) async {
      await tester.pumpWidget(const HermitProvApp());

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, equals(0));
    });

    testWidgets('History tab is reachable', (WidgetTester tester) async {
      await tester.pumpWidget(const HermitProvApp());

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('History'),
        ),
      );
      await tester.pump();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, equals(1));
    });

    testWidgets('Settings tab is reachable', (WidgetTester tester) async {
      await tester.pumpWidget(const HermitProvApp());

      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pump();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, equals(2));
    });
  });
}
