import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbg/features/authentication/presentation/login_screen.dart';

void main() {
  testWidgets('Test clicking role animation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Tap the 'Orang Tua' role
    final orangTuaFinder = find.text('Orang Tua');
    expect(orangTuaFinder, findsOneWidget);

    await tester.tap(orangTuaFinder);
    
    // Wait for animation to finish
    await tester.pumpAndSettle();

    // Tap another role
    final kurirFinder = find.text('Kurir');
    expect(kurirFinder, findsOneWidget);

    await tester.tap(kurirFinder);
    await tester.pumpAndSettle();

    // If it reaches here without exceptions, test passes
    expect(true, isTrue);
  });
}
