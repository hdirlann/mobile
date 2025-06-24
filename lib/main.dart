import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:utsmobile/pages/home.dart';
import 'package:utsmobile/pages/menu.dart';
import 'package:utsmobile/pages/profile.dart';
import 'package:utsmobile/pages/login.dart';
import 'package:utsmobile/pages/register.dart';
import 'package:utsmobile/pages/menu_detail.dart';
import 'package:utsmobile/pages/article.dart';
import 'package:utsmobile/pages/article_detail.dart';
import 'package:utsmobile/pages/edit_profile.dart';
import 'package:utsmobile/pages/favorites.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan penanganan error
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Anda bisa menambahkan logika untuk menampilkan error ke UI jika diperlukan
  }

  // Inisialisasi SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTS Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/menu': (context) => const MenuScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/menuDetail': (context) => const MenuDetailScreen(),
        '/article': (context) => const ArticleScreen(),
        '/articleDetail': (context) => const ArticleDetailScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
      // Tambahkan navigator key untuk kontrol navigasi global jika diperlukan
      // navigatorKey: navigatorKey,
    );
  }
}