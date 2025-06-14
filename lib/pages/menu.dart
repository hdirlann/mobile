import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:utsmobile/pages/menu_detail.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late List<Map<String, dynamic>> menuItems;
  List<String> favoriteMenuNames = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
    _loadFavorites();
  }

  Future<void> _loadMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? menuItemsJson = prefs.getString('menu_items');
    if (menuItemsJson != null) {
      setState(() {
        menuItems = List<Map<String, dynamic>>.from(jsonDecode(menuItemsJson));
      });
    } else {
      setState(() {
        menuItems = const [
          {
            'name': 'Avocado Toast',
            'iconPath': 'assets/icons/avocado.svg',
            'description': 'Toasted bread with fresh avocado',
            'calories': '200 kcal',
            'duration': '10 mins',
            'recipe': [
              'Toast the bread until golden brown.',
              'Mash the avocado with a fork and spread it on the toast.',
              'Add a pinch of salt and pepper to taste.',
              'Optional: Top with a fried egg or cherry tomatoes.',
            ],
          },
          {
            'name': 'Fruit Smoothie',
            'iconPath': 'assets/icons/smoothie.svg',
            'description': 'Mixed berries and banana smoothie',
            'calories': '150 kcal',
            'duration': '5 mins',
            'recipe': [
              'Add mixed berries and banana to a blender.',
              'Pour in 1 cup of milk or yogurt.',
              'Blend until smooth.',
              'Serve chilled and enjoy immediately.',
            ],
          },
          {
            'name': 'Greek Salad',
            'iconPath': 'assets/icons/salad.svg',
            'description': 'Fresh vegetables with feta cheese',
            'calories': '180 kcal',
            'duration': '15 mins',
            'recipe': [
              'Chop cucumbers, tomatoes, and red onions into bite-sized pieces.',
              'Crumble feta cheese and add to the vegetables.',
              'Mix olive oil, lemon juice, salt, and pepper for dressing.',
              'Toss everything together and serve fresh.',
            ],
          },
        ];
        _saveMenuItems();
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorite_menus');
    if (favoritesJson != null) {
      setState(() {
        favoriteMenuNames = List<String>.from(jsonDecode(favoritesJson));
      });
    }
  }

  Future<void> _saveMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('menu_items', jsonEncode(menuItems));
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_menus', jsonEncode(favoriteMenuNames));
  }

  void _addMenuItem(Map<String, dynamic> newItem) {
    setState(() {
      menuItems.add(newItem);
    });
    _saveMenuItems();
  }

  void _updateMenuItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      menuItems[index] = updatedItem;
    });
    _saveMenuItems();
  }

  void _deleteMenuItem(int index) {
    setState(() {
      menuItems.removeAt(index);
    });
    _saveMenuItems();
  }

  void _toggleFavorite(String menuName, bool isFavorite) {
    setState(() {
      if (isFavorite && !favoriteMenuNames.contains(menuName)) {
        favoriteMenuNames.add(menuName);
      } else if (!isFavorite && favoriteMenuNames.contains(menuName)) {
        favoriteMenuNames.remove(menuName);
      }
    });
    _saveFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFavorite ? '$menuName added to favorites' : '$menuName removed from favorites')),
    );
  }

  void _showAddMenuDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _iconPathController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _durationController = TextEditingController();
    List<String> recipeSteps = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Menu Item'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _iconPathController,
                    decoration: const InputDecoration(labelText: 'Icon Path (e.g., assets/icons/avocado.svg)'),
                    validator: (value) => value!.isEmpty ? 'Please enter an icon path' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories (e.g., 200 kcal)'),
                    validator: (value) => value!.isEmpty ? 'Please enter calories' : null,
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duration (e.g., 10 mins)'),
                    validator: (value) => value!.isEmpty ? 'Please enter duration' : null,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final _recipeController = TextEditingController();
                          return AlertDialog(
                            title: const Text('Add Recipe Step'),
                            content: TextField(
                              controller: _recipeController,
                              decoration: const InputDecoration(labelText: 'Step'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (_recipeController.text.isNotEmpty) {
                                    setState(() {
                                      recipeSteps.add(_recipeController.text);
                                    });
                                    _recipeController.clear();
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Add Recipe Step'),
                  ),
                  const SizedBox(height: 10),
                  if (recipeSteps.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipeSteps.map((step) => Text('- $step')).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && recipeSteps.isNotEmpty) {
                  final newItem = {
                    'name': _nameController.text,
                    'iconPath': _iconPathController.text,
                    'description': _descriptionController.text,
                    'calories': _caloriesController.text,
                    'duration': _durationController.text,
                    'recipe': recipeSteps,
                  };
                  _addMenuItem(newItem);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMenuDialog(int index) {
    final item = menuItems[index];
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: item['name']);
    final _iconPathController = TextEditingController(text: item['iconPath']);
    final _descriptionController = TextEditingController(text: item['description']);
    final _caloriesController = TextEditingController(text: item['calories']);
    final _durationController = TextEditingController(text: item['duration']);
    List<String> recipeSteps = List<String>.from(item['recipe']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Menu Item'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _iconPathController,
                    decoration: const InputDecoration(labelText: 'Icon Path'),
                    validator: (value) => value!.isEmpty ? 'Please enter an icon path' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    validator: (value) => value!.isEmpty ? 'Please enter calories' : null,
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    validator: (value) => value!.isEmpty ? 'Please enter duration' : null,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final _recipeController = TextEditingController();
                          return AlertDialog(
                            title: const Text('Edit Recipe Step'),
                            content: TextField(
                              controller: _recipeController,
                              decoration: const InputDecoration(labelText: 'Step'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (_recipeController.text.isNotEmpty) {
                                    setState(() {
                                      recipeSteps.add(_recipeController.text);
                                    });
                                    _recipeController.clear();
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Add Recipe Step'),
                  ),
                  const SizedBox(height: 10),
                  if (recipeSteps.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipeSteps.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final step = entry.value;
                        return Row(
                          children: [
                            Expanded(child: Text('- $step')),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  recipeSteps.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && recipeSteps.isNotEmpty) {
                  final updatedItem = {
                    'name': _nameController.text,
                    'iconPath': _iconPathController.text,
                    'description': _descriptionController.text,
                    'calories': _caloriesController.text,
                    'duration': _durationController.text,
                    'recipe': recipeSteps,
                  };
                  _updateMenuItem(index, updatedItem);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMenuDialog,
            color: const Color(0xff92A3FD),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isFavorite = favoriteMenuNames.contains(item['name']);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/menuDetail',
                        arguments: item,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff1D1617).withOpacity(0.07),
                            offset: const Offset(0, 10),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            item['iconPath'],
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  item['description'],
                                  style: const TextStyle(
                                    color: Color(0xff7B6F72),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${item['calories']} | ${item['duration']}',
                                  style: const TextStyle(
                                    color: Color(0xff7B6F72),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _toggleFavorite(item['name'], !isFavorite);
                                },
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: const Color(0xff92A3FD),
                                onPressed: () => _showEditMenuDialog(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deleteMenuItem(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}