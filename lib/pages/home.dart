import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:utsmobile/models/category_model.dart';
import 'package:utsmobile/models/diet_model.dart';
import 'package:utsmobile/models/popular_model.dart';
import 'package:utsmobile/pages/menu.dart';
import 'package:utsmobile/pages/profile.dart';
import 'package:utsmobile/pages/article.dart';
import 'package:utsmobile/pages/kategori.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<CategoryModel>? categories;
  List<DietModel>? diets;
  List<PopularDietsModel>? popularDiets;
  List<String> favoriteNames = [];
  int _selectedCategoryIndex = -1;
  bool _isLoading = true;

  Future<void> _loadInitialInfo() async {
    try {
      final loadedCategories = CategoryModel.getCategories();
      final loadedDiets = await DietModel.getDiets();
      final loadedPopularDiets = PopularDietsModel.getPopularDiets();
      setState(() {
        categories = loadedCategories;
        diets = loadedDiets;
        popularDiets = loadedPopularDiets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial info: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorite_diets');
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      setState(() {
        favoriteNames = favoritesList.map((item) => item as String).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialInfo();
    _loadFavorites();
  }

  Future<void> _toggleFavorite(PopularDietsModel diet, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteNamesList = prefs.getString('favorite_diets') != null
        ? (jsonDecode(prefs.getString('favorite_diets')!) as List<dynamic>)
        .map((item) => item as String)
        .toList()
        : [];

    if (isFavorite) {
      if (!favoriteNamesList.contains(diet.name)) {
        favoriteNamesList.add(diet.name);
      }
    } else {
      favoriteNamesList.remove(diet.name);
    }

    await prefs.setString('favorite_diets', jsonEncode(favoriteNamesList));
    setState(() {
      favoriteNames = favoriteNamesList;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${diet.name} ditambahkan ke favorit'
              : '${diet.name} dihapus dari favorit',
        ),
      ),
    );
    print('Daftar diet favorit diperbarui: $favoriteNamesList');
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      ).then((_) {
        _loadInitialInfo(); // Muat ulang data setelah kembali dari MenuScreen
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || categories == null || diets == null || popularDiets == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      HomeContent(
        categories: categories!,
        diets: diets!,
        popularDiets: popularDiets!,
        favoriteNames: favoriteNames,
        onFavoriteToggled: _toggleFavorite,
        selectedCategoryIndex: _selectedCategoryIndex,
        onCategoryTapped: (index) {
          setState(() {
            _selectedCategoryIndex = index;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KategoriScreen(
                category: categories![index],
                diets: diets!
                    .where((diet) => diet.category == categories![index].name)
                    .toList(),
              ),
            ),
          ).then((_) {
            setState(() {
              _selectedCategoryIndex = -1;
            });
          });
        },
      ),
      const MenuScreen(),
      const ArticleScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          print("Pop dipanggil, tetapi diblokir");
        }
      },
      child: Scaffold(
        body: pages[_selectedIndex],
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

class HomeContent extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<DietModel> diets;
  final List<PopularDietsModel> popularDiets;
  final List<String> favoriteNames;
  final Function(PopularDietsModel, bool) onFavoriteToggled;
  final int selectedCategoryIndex;
  final Function(int) onCategoryTapped;

  const HomeContent({
    super.key,
    required this.categories,
    required this.diets,
    required this.popularDiets,
    required this.favoriteNames,
    required this.onFavoriteToggled,
    required this.selectedCategoryIndex,
    required this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _searchField(),
          const SizedBox(height: 40),
          _categoriesSection(context),
          const SizedBox(height: 40),
          _dietSection(),
          const SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Populer',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ListView.separated(
                itemCount: popularDiets.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const SizedBox(height: 25),
                padding: const EdgeInsets.only(left: 20, right: 20),
                itemBuilder: (context, index) {
                  final diet = popularDiets[index];
                  final isFavorite = favoriteNames.contains(diet.name);
                  return Container(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          diet.iconPath,
                          width: 65,
                          height: 65,
                          placeholderBuilder: (context) => const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${diet.level} | ${diet.duration} | ${diet.calorie}',
                              style: const TextStyle(
                                color: Color(0xff7B6F72),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            onFavoriteToggled(diet, !isFavorite);
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: diet.boxIsSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: diet.boxIsSelected
                          ? [
                        BoxShadow(
                          color: const Color(0xff1D1617).withOpacity(0.07),
                          offset: const Offset(0, 10),
                          blurRadius: 40,
                          spreadRadius: 0,
                        ),
                      ]
                          : [],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Sarapan',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 37,
          child: SvgPicture.asset(
            'assets/icons/dots.svg',
            height: 5,
            width: 5,
            placeholderBuilder: (context) => const Icon(
              Icons.error,
              color: Colors.red,
              size: 24,
            ),
          ),
          decoration: BoxDecoration(
            color: const Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Column _dietSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Rekomendasi\nuntuk Diet',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 240,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return Container(
                width: 210,
                decoration: BoxDecoration(
                  color: diets[index].boxColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      diets[index].iconPath,
                      placeholderBuilder: (context) => const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          diets[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${diets[index].level} | ${diets[index].duration} | ${diets[index].calorie}',
                          style: const TextStyle(
                            color: Color(0xff7B6F72),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 45,
                      width: 130,
                      child: Center(
                        child: Text(
                          'Lihat',
                          style: TextStyle(
                            color: diets[index].viewIsSelected
                                ? Colors.white
                                : const Color(0xffC58BF2),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            diets[index].viewIsSelected
                                ? const Color(0xff9DCEFF)
                                : Colors.transparent,
                            diets[index].viewIsSelected
                                ? const Color(0xff92A3FD)
                                : Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemCount: diets.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
          ),
        ),
      ],
    );
  }

  Column _categoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Kategori',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 120,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              final isSelected = selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => onCategoryTapped(index),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: categories[index].boxColor.withOpacity(isSelected ? 0.5 : 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: const Color(0xff92A3FD), width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.07),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            categories[index].iconPath,
                            color: isSelected ? const Color(0xff92A3FD) : null,
                            placeholderBuilder: (context) => const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        categories[index].name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? const Color(0xff92A3FD) : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Container _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Cari Pancake',
          hintStyle: const TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/Search.svg',
              placeholderBuilder: (context) => const Icon(
                Icons.error,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
          suffixIcon: Container(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/icons/Filter.svg',
                      placeholderBuilder: (context) => const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}