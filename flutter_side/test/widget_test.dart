// Basic smoke test: verifies the app builds and renders its landing page.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:btk_byte_benders/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RiskRadarLandingPage());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
