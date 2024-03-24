import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trelltech/main.dart' as app;
import 'package:trelltech/views/dashboard/dashboard_view.dart';
import 'package:trelltech/views/discover_app/discover_app_view.dart';
import 'package:trelltech/views/home/home_view.dart';
import 'package:patrol/patrol.dart';

void main() async {
  patrolTest(
      'Authorize',
      ($) async {
        await $.pumpWidgetAndSettle(const app.MyApp());
        await $.pumpAndSettle();
        expect(find.byType(HomeView), findsOneWidget);
        // await $.tap(find.byKey(const Key('discover_button')));
        // await $.pumpAndSettle();
        // expect(find.byType(DiscoverAppView), findsOneWidget);
        // await $.tap(find.byKey(const Key('connect_button')));
        // await $.pumpAndSettle();
        // await $.native.tap(Selector(text: 'Autoriser'));
        // await $.pumpAndSettle();
        // expect(find.byType(DashboardView), findsOneWidget);
      },
  );
}
