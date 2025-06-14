import 'package:flutter/material.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/login',
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
    );
  }
}