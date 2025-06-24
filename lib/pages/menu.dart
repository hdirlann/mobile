import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Impor untuk jsonDecode dan jsonEncode
import 'package:utsmobile/models/category_model.dart';
import 'package:utsmobile/pages/menu_detail.dart';
import 'package:utsmobile/pages/home.dart';
import 'package:utsmobile/pages/article.dart';
import 'package:utsmobile/pages/profile.dart';

class MenuScreen extends StatefulWidget {
  final String? selectedCategory;

  const MenuScreen({super.key, this.selectedCategory});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 1; // Default ke 'Menu'
  List<Map<String, dynamic>> menuItems = [];
  List<String> favoriteMenuNames = [];
  bool _isLoading = true;
  late List<CategoryModel> categories;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    categories = CategoryModel.getCategories();
    _fetchMenuItems(); // Ambil data dari Firestore
  }

  Future<void> _fetchMenuItems() async {
    try {
      setState(() => _isLoading = true);
      QuerySnapshot querySnapshot = await _firestore.collection('menus').get();
      setState(() {
        menuItems = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id, // ID dokumen untuk referensi
            'name': data['name'] ?? 'No Name',
            'iconPath': data['iconPath'] ??
                categories.firstWhere((cat) => cat.name == (data['category'] ?? 'Salad'),
                    orElse: () => CategoryModel(name: 'Salad', iconPath: 'assets/icons/plate.svg', boxColor: Colors.white)).iconPath,
            'isSvg': data['isSvg'] ?? true,
            'description': data['description'] ?? 'No Description',
            'calories': data['calories'] ?? 'N/A',
            'duration': data['duration'] ?? 'N/A',
            'recipe': data['recipe'] ?? [],
            'category': data['category'] ?? 'Salad',
          };
        }).toList();
        _isLoading = false;
      });
      print('Menu items fetched from Firestore: ${menuItems.length} items');
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching menu items: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorite_menus');
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final decoded = jsonDecode(favoritesJson); // Gunakan jsonDecode
        if (decoded is List) {
          setState(() {
            favoriteMenuNames = List<String>.from(decoded);
          });
          print('Favorites loaded: ${favoriteMenuNames.length} items');
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(favoriteMenuNames); // Gunakan jsonEncode
      await prefs.setString('favorite_menus', encoded);
      print('Favorites saved: ${favoriteMenuNames.length} items');
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  Future<void> _addMenuItem(Map<String, dynamic> newItem) async {
    try {
      final docRef = await _firestore.collection('menus').add(newItem);
      setState(() {
        menuItems.add({...newItem, 'id': docRef.id});
      });
      print('Item ditambahkan: $newItem');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newItem['name']} berhasil ditambahkan')),
      );
    } catch (e) {
      print('Error adding menu item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan item')),
      );
    }
  }

  Future<void> _updateMenuItem(int index, Map<String, dynamic> updatedItem) async {
    try {
      final item = menuItems[index];
      await _firestore.collection('menus').doc(item['id']).update(updatedItem);
      setState(() {
        menuItems[index] = {...updatedItem, 'id': item['id']};
      });
      print('Item diperbarui: $updatedItem');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedItem['name']} berhasil diperbarui')),
      );
    } catch (e) {
      print('Error updating menu item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui item')),
      );
    }
  }

  Future<void> _deleteMenuItem(int index) async {
    try {
      final item = menuItems[index];
      await _firestore.collection('menus').doc(item['id']).delete();
      setState(() {
        menuItems.removeAt(index);
      });
      print('Item dihapus: ${item['name']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item['name']} berhasil dihapus')),
      );
    } catch (e) {
      print('Error deleting menu item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus item')),
      );
    }
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
      SnackBar(content: Text(isFavorite ? '$menuName ditambahkan ke favorit' : '$menuName dihapus dari favorit')),
    );
  }

  void _showAddMenuDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _caloriesController = TextEditingController();
    final _durationController = TextEditingController();
    List<String> recipeSteps = [];
    String? _selectedCategory = categories.isNotEmpty ? categories[0].name : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Item Menu Baru'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan nama';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: categories.map((CategoryModel category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  category.iconPath,
                                  width: 20,
                                  height: 20,
                                  placeholderBuilder: (context) => const Icon(Icons.error),
                                ),
                                const SizedBox(width: 10),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Pilih kategori' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Path Gambar Ikon (kosongkan untuk pakai ikon kategori)'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !value.startsWith('assets/')) {
                            return 'Path harus dimulai dengan "assets/" jika diisi';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setDialogState(() {});
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Deskripsi'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan deskripsi';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(labelText: 'Kalori (contoh: 200 kcal)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan kalori';
                          if (!RegExp(r'^\d+ kcal$').hasMatch(value)) return 'Format: contoh, 200 kcal';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Durasi (contoh: 10 menit)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan durasi';
                          if (!RegExp(r'^\d+ menit$').hasMatch(value)) return 'Format: contoh, 10 menit';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final _recipeController = TextEditingController();
                              return AlertDialog(
                                title: const Text('Tambah Langkah Resep'),
                                content: TextField(
                                  controller: _recipeController,
                                  decoration: const InputDecoration(labelText: 'Langkah'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      if (_recipeController.text.isNotEmpty) {
                                        setDialogState(() {
                                          recipeSteps.add(_recipeController.text);
                                        });
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Masukkan langkah resep')),
                                        );
                                      }
                                    },
                                    child: const Text('Tambah'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Tambah Langkah Resep'),
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
                                    setDialogState(() {
                                      recipeSteps.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      if (recipeSteps.isEmpty)
                        const Text(
                          'Belum ada langkah resep. Tambahkan setidaknya satu langkah.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                        'iconPath': categories.firstWhere((cat) => cat.name == _selectedCategory).iconPath,
                        'isSvg': true,
                        'description': _descriptionController.text,
                        'calories': _caloriesController.text,
                        'duration': _durationController.text,
                        'recipe': recipeSteps,
                        'category': _selectedCategory,
                      };
                      _addMenuItem(newItem);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tambahkan setidaknya satu langkah resep')),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMenuDialog(int index) {
    final item = menuItems[index];
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: item['name']);
    final _descriptionController = TextEditingController(text: item['description']);
    final _caloriesController = TextEditingController(text: item['calories']);
    final _durationController = TextEditingController(text: item['duration']);
    List<String> recipeSteps = List<String>.from(item['recipe'] ?? []);
    String? _selectedCategory = item['category'] ?? (categories.isNotEmpty ? categories[0].name : null);
    bool _isSvg = item['isSvg'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Item Menu'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan nama';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: categories.map((CategoryModel category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  category.iconPath,
                                  width: 20,
                                  height: 20,
                                  placeholderBuilder: (context) => const Icon(Icons.error),
                                ),
                                const SizedBox(width: 10),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Pilih kategori' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: item['iconPath'] ?? '',
                        decoration: const InputDecoration(labelText: 'Path Gambar Ikon (kosongkan untuk pakai ikon kategori)'),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !value.startsWith('assets/')) return 'Path harus dimulai dengan "assets/" jika diisi';
                          return null;
                        },
                        onChanged: (value) {
                          setDialogState(() {
                            _isSvg = value.isEmpty || value.endsWith('.svg');
                          });
                        },
                      ),
                      if ((item['iconPath'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _isSvg
                            ? SvgPicture.asset(
                          item['iconPath']!,
                          width: 100,
                          height: 100,
                          placeholderBuilder: (context) => const Icon(Icons.error),
                        )
                            : Image.asset(
                          item['iconPath']!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                      ],
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Deskripsi'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan deskripsi';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(labelText: 'Kalori (contoh: 200 kcal)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan kalori';
                          if (!RegExp(r'^\d+ kcal$').hasMatch(value)) return 'Format: contoh, 200 kcal';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Durasi (contoh: 10 menit)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan durasi';
                          if (!RegExp(r'^\d+ menit$').hasMatch(value)) return 'Format: contoh, 10 menit';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final _recipeController = TextEditingController();
                              return AlertDialog(
                                title: const Text('Tambah Langkah Resep'),
                                content: TextField(
                                  controller: _recipeController,
                                  decoration: const InputDecoration(labelText: 'Langkah'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      if (_recipeController.text.isNotEmpty) {
                                        setDialogState(() {
                                          recipeSteps.add(_recipeController.text);
                                        });
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Masukkan langkah resep')),
                                        );
                                      }
                                    },
                                    child: const Text('Tambah'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Tambah Langkah Resep'),
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
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final _editController = TextEditingController(text: step);
                                        return AlertDialog(
                                          title: const Text('Edit Langkah Resep'),
                                          content: TextField(
                                            controller: _editController,
                                            decoration: const InputDecoration(labelText: 'Langkah'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                if (_editController.text.isNotEmpty) {
                                                  setDialogState(() {
                                                    recipeSteps[idx] = _editController.text;
                                                  });
                                                  Navigator.pop(context);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Masukkan langkah resep')),
                                                  );
                                                }
                                              },
                                              child: const Text('Simpan'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setDialogState(() {
                                      recipeSteps.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      if (recipeSteps.isEmpty)
                        const Text(
                          'Belum ada langkah resep. Tambahkan setidaknya satu langkah.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                        'iconPath': item['iconPath'] ?? categories.firstWhere((cat) => cat.name == _selectedCategory).iconPath,
                        'isSvg': _isSvg,
                        'description': _descriptionController.text,
                        'calories': _caloriesController.text,
                        'duration': _durationController.text,
                        'recipe': recipeSteps,
                        'category': _selectedCategory,
                      };
                      _updateMenuItem(index, updatedItem);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tambahkan setidaknya satu langkah resep')),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 1;
          });
          _fetchMenuItems();
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 1;
          });
          _fetchMenuItems();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenuItems = widget.selectedCategory == null
        ? menuItems
        : menuItems.where((item) => item['category'] == widget.selectedCategory).toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          print("Pop dipanggil, tetapi diblokir");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Menu${widget.selectedCategory != null ? ' - ${widget.selectedCategory}' : ''}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          leading: widget.selectedCategory != null
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddMenuDialog,
              color: const Color(0xff92A3FD),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredMenuItems.isEmpty
            ? const Center(child: Text('Tidak ada item menu untuk kategori ini. Tambahkan item baru.'))
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu${widget.selectedCategory != null ? ' - ${widget.selectedCategory}' : ''}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredMenuItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final item = filteredMenuItems[index];
                    final isFavorite = favoriteMenuNames.contains(item['name']);
                    final isSvg = item['isSvg'] ?? true;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          MenuDetailScreen.routeName,
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
                            isSvg
                                ? SvgPicture.asset(
                              item['iconPath'] ?? 'assets/icons/default.svg',
                              width: 50,
                              height: 50,
                              placeholderBuilder: (context) => const Icon(Icons.error),
                            )
                                : (item['iconPath'] != null && item['iconPath'].isNotEmpty)
                                ? Image.asset(
                              item['iconPath'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            )
                                : const Icon(Icons.image, size: 50),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'Nama Tidak Tersedia',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    item['category'] ?? 'No Category',
                                    style: const TextStyle(
                                      color: Color(0xff7B6F72),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    item['description'] ?? 'Deskripsi Tidak Tersedia',
                                    style: const TextStyle(
                                      color: Color(0xff7B6F72),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${item['calories'] ?? 'N/A'} | ${item['duration'] ?? 'N/A'}',
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
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Item'),
                                        content: Text('Apakah Anda yakin ingin menghapus ${item['name']}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteMenuItem(index);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 24,
                width: 24,
                color: _selectedIndex == 0 ? const Color(0xff92A3FD) : Colors.grey,
                placeholderBuilder: (context) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/menu_book.svg',
                height: 24,
                width: 24,
                color: _selectedIndex == 1 ? const Color(0xff92A3FD) : Colors.grey,
                placeholderBuilder: (context) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/article.svg',
                height: 24,
                width: 24,
                color: _selectedIndex == 2 ? const Color(0xff92A3FD) : Colors.grey,
                placeholderBuilder: (context) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/person.svg',
                height: 24,
                width: 24,
                color: _selectedIndex == 3 ? const Color(0xff92A3FD) : Colors.grey,
                placeholderBuilder: (context) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff92A3FD),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}