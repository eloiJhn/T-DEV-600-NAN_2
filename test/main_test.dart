import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trelltech/views/dashboard/dashboard_view.dart';

void main() {
  testWidgets('DashboardView test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DashboardView()));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}