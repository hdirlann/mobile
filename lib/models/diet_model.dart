import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DietModel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  Color boxColor;
  bool viewIsSelected;
  String category;

  DietModel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.duration,
    required this.calorie,
    required this.boxColor,
    required this.viewIsSelected,
    required this.category,
  });

  factory DietModel.fromMap(Map<String, dynamic> map) {
    return DietModel(
      name: map['name'] ?? 'Nama Tidak Tersedia',
      iconPath: map['iconPath'] ?? 'assets/icons/default.svg',
      level: map['level'] ?? 'Mudah',
      duration: map['duration'] ?? 'N/A',
      calorie: map['calories'] ?? 'N/A',
      boxColor: Color(int.parse(map['boxColor'] ?? '0xff9DCEFF')),
      viewIsSelected: map['viewIsSelected'] ?? false,
      category: map['category'] ?? 'Salad', // Default ke 'Salad' agar sesuai dengan category_model.dart
    );
  }

  static Future<List<DietModel>> getDiets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? menuItemsJson = prefs.getString('menu_items');
    List<DietModel> diets = [];

    if (menuItemsJson != null && menuItemsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(menuItemsJson);
        if (decoded is List) {
          diets = decoded
              .map((item) => DietModel.fromMap(Map<String, dynamic>.from(item)))
              .toList();
        }
      } catch (e) {
        print('Error decoding menu items: $e');
      }
    }

    if (diets.isEmpty) {
      diets = [
        DietModel(
          name: 'Avocado Toast',
          iconPath: 'assets/icons/plate.svg', // Sesuai dengan kategori Salad
          level: 'Mudah',
          duration: '10 menit',
          calorie: '200 kcal',
          boxColor: Color(0xff9DCEFF), // Sesuai dengan kategori Salad
          viewIsSelected: true,
          category: 'Salad',
        ),
        DietModel(
          name: 'Fruit Smoothie',
          iconPath: 'assets/icons/orange-snacks.svg', // Sesuai dengan kategori Smoothies
          level: 'Mudah',
          duration: '5 menit',
          calorie: '150 kcal',
          boxColor: Color(0xffEEA4CE), // Sesuai dengan kategori Smoothies
          viewIsSelected: false,
          category: 'Smoothies',
        ),
        DietModel(
          name: 'Greek Salad',
          iconPath: 'assets/icons/plate.svg', // Sesuai dengan kategori Salad
          level: 'Mudah',
          duration: '15 menit',
          calorie: '180 kcal',
          boxColor: Color(0xff9DCEFF), // Sesuai dengan kategori Salad
          viewIsSelected: true,
          category: 'Salad',
        ),
      ];
      await prefs.setString(
        'menu_items',
        jsonEncode(diets.map((diet) => {
          'name': diet.name,
          'iconPath': diet.iconPath,
          'level': diet.level,
          'duration': diet.duration,
          'calories': diet.calorie,
          'boxColor': '0x${diet.boxColor.value.toRadixString(16)}',
          'viewIsSelected': diet.viewIsSelected,
          'category': diet.category,
          'isSvg': true, // Sesuai dengan menu.dart
          'description': diet.name == 'Avocado Toast'
              ? 'Roti panggang dengan alpukat segar'
              : diet.name == 'Fruit Smoothie'
              ? 'Smoothie campuran beri dan pisang'
              : 'Sayuran segar dengan keju feta',
          'recipe': diet.name == 'Avocado Toast'
              ? [
            'Panggang roti hingga kecokelatan.',
            'Hancurkan alpukat dengan garpu dan oleskan ke roti.',
            'Tambahkan sedikit garam dan merica sesuai selera.',
            'Opsional: Tambahkan telur goreng atau tomat ceri di atasnya.',
          ]
              : diet.name == 'Fruit Smoothie'
              ? [
            'Masukkan beri campur dan pisang ke blender.',
            'Tambahkan 1 cangkir susu atau yogurt.',
            'Blender hingga halus.',
            'Sajikan dingin dan nikmati segera.',
          ]
              : [
            'Potong timun, tomat, dan bawang merah menjadi potongan kecil.',
            'Hancurkan keju feta dan tambahkan ke sayuran.',
            'Campur minyak zaitun, jus lemon, garam, dan merica untuk dressing.',
            'Aduk semua bahan dan sajikan segar.',
          ],
        }).toList()),
      );
    }

    return diets;
  }
}