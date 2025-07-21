// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analyze_foodapp/main.dart'; // Veya WelcomeScreen'in tanımlandığı dosya yolu
void main() {
  testWidgets('Welcome screen shows correct initial content', (WidgetTester tester) async {
    // Widget'i test ortamına yükle
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Varsayılan dil Türkçe olarak "Merhaba!" yazısı görünmeli
    expect(find.text('Merhaba!'), findsOneWidget);

    // "Devam Et" butonu görünmeli
    expect(find.text('Devam Et'), findsOneWidget);

    // Dil seçimi dropdown'ı görünmeli
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // En az 1 ikon (Image.asset) görünmeli
    expect(find.byType(Image), findsWidgets);
  });
}




