// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepnode/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame. PrepNodeApp is a ConsumerWidget —
    // it requires a ProviderScope ancestor (exactly as main() provides one
    // at real app startup) or every ref.watch() throws "No ProviderScope
    // found" before a single frame renders. The test never had one; this
    // was a pre-existing failure unrelated to Phase 1B's schema/seed work,
    // caught by actually running the test rather than assuming it worked.
    await tester.pumpWidget(const ProviderScope(child: PrepNodeApp()));
    
    // Pump and settle with timeout to handle any async operations
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that the app launches without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
