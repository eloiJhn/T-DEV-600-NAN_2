import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';
import 'package:trelltech/views/home/home_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('end-to-end test', () {
    testWidgets('finds the discover button and taps it to navigate to the DiscoverAppView', (WidgetTester tester) async {
      // Build the HomeView widget.
      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      // Find the discover button.
      final discoverButton = find.byKey(const Key('discover_button'));

      // Check that the discover button is in the widget tree.
      expect(discoverButton, findsOneWidget);

      // Tap the discover button.
      await tester.tap(discoverButton);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Check that the DiscoverAppView is in the widget tree.
      expect(find.byType(DiscoverAppView), findsOneWidget);
    });
  });
}