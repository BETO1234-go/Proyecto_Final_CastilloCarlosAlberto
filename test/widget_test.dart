// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:examen_final/app/app.dart';
import 'package:examen_final/features/inventory/data/repositories/inventory_repository.dart';
import 'package:examen_final/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads dashboard shell', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(
            InMemoryInventoryRepository(),
          ),
        ],
        child: const InventoryApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Centro de Control'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard_outlined), findsWidgets);
  });
}
