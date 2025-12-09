// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_community_connect_app/app/app.dart';
import 'package:local_community_connect_app/app/router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final router = createRouter(showOnboarding: false);

    await tester.pumpWidget(
      ProviderScope(
        child: CommunityConnectApp(router: router),
      ),
    );

    // Wait for async initialization (use pump with duration to avoid timeout with async providers)
    await tester.pump(const Duration(seconds: 2));

    // Verify that the initial screen (Events) is shown.
    expect(find.text('Events'), findsAtLeastNWidgets(1));

    // Example: Verify that the bottom navigation bar is present
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
