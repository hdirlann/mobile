import 'package:flutter/material.dart';

class PopularDietsModel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  bool boxIsSelected;

  PopularDietsModel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.duration,
    required this.calorie,
    this.boxIsSelected = false,
  });

  static List<PopularDietsModel> getPopularDiets() {
    return [
      PopularDietsModel(
        name: 'Blueberry Pancake',
        iconPath: 'assets/icons/blueberry-pancake.svg',
        level: 'Medium',
        duration: '30mins',
        calorie: '230kCal',
        boxIsSelected: true,
      ),
      PopularDietsModel(
        name: 'Salmon Salad',
        iconPath: 'assets/icons/salmon-salad.svg',
        level: 'Easy',
        duration: '20mins',
        calorie: '180kCal',
        boxIsSelected: false,
      ),
    ];
  }
}