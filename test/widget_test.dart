import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utsmobile/main.dart';

void main() {
  testWidgets('Menampilkan halaman login jika belum login', (WidgetTester tester) async {
    // Bangun widget dengan status belum login
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    // Pastikan teks 'Welcome Back!' tampil
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Cek tombol login ada
    expect(find.text('Login'), findsOneWidget);

    // Cek field Email dan Password muncul
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });

  testWidgets('Tombol login membawa ke halaman home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    // Tekan tombol login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Ganti ini sesuai widget atau teks yang muncul di HomePage
    expect(find.text('Home'), findsOneWidget); // Sesuaikan jika perlu
  });

  testWidgets('Menampilkan halaman home jika sudah login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));
    await tester.pumpAndSettle();

    // Ganti dengan sesuatu yang khas dari halaman home
    expect(find.text('Home'), findsOneWidget); // Sesuaikan jika perlu
  });
}
