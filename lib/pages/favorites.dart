import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsmobile/models/article_model.dart';
import 'package:utsmobile/models/popular_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ArticleModel> favoriteArticles = [];
  List<PopularDietsModel> favoriteDiets = [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Resep favorit
    final String? articlesJson = prefs.getString('articles_cache');
    final String? favoriteArticleIdsJson = prefs.getString('favorite_articles');
    print('Articles cache: $articlesJson');
    print('Favorite articles: $favoriteArticleIdsJson');
    if (articlesJson != null && favoriteArticleIdsJson != null) {
      final List<dynamic> articlesList = jsonDecode(articlesJson);
      final List<int> favoriteIds = List<int>.from(jsonDecode(favoriteArticleIdsJson));
      final List<ArticleModel> articles = articlesList
          .map((json) => ArticleModel.fromJson(json))
          .where((article) => favoriteIds.contains(article.id))
          .toList();
      setState(() {
        favoriteArticles = articles;
      });
      print('Favorite articles loaded: ${favoriteArticles.map((e) => e.title).toList()}');
    } else {
      print('No articles cache or favorite articles found');
    }
    // Diet favorit
    final String? favoriteDietNamesJson = prefs.getString('favorite_diets');
    print('Favorite diets: $favoriteDietNamesJson');
    if (favoriteDietNamesJson != null) {
      final List<String> favoriteDietNames = List<String>.from(jsonDecode(favoriteDietNamesJson));
      final List<PopularDietsModel> allDiets = PopularDietsModel.getPopularDiets();
      final List<PopularDietsModel> diets =
      allDiets.where((diet) => favoriteDietNames.contains(diet.name)).toList();
      setState(() {
        favoriteDiets = diets;
      });
      print('Favorite diets loaded: ${favoriteDiets.map((e) => e.name).toList()}');
    }
  }

  Future<void> _removeFavoriteArticle(int articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoriteIdsJson = prefs.getString('favorite_articles');
    if (favoriteIdsJson != null) {
      List<int> favoriteIds = List<int>.from(jsonDecode(favoriteIdsJson));
      favoriteIds.remove(articleId);
      await prefs.setString('favorite_articles', jsonEncode(favoriteIds));
      setState(() {
        favoriteArticles.removeWhere((article) => article.id == articleId);
      });
      print('Article removed from favorites: $articleId');
    }
  }

  Future<void> _toggleFavoriteDiet(String dietName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoriteDietNamesJson = prefs.getString('favorite_diets');
    List<String> favoriteDietNames =
    favoriteDietNamesJson != null ? List<String>.from(jsonDecode(favoriteDietNamesJson)) : [];
    setState(() {
      if (favoriteDietNames.contains(dietName)) {
        favoriteDietNames.remove(dietName);
        favoriteDiets.removeWhere((diet) => diet.name == dietName);
      } else {
        favoriteDietNames.add(dietName);
        final diet = PopularDietsModel.getPopularDiets().firstWhere((diet) => diet.name == dietName);
        favoriteDiets.add(diet);
      }
    });
    await prefs.setString('favorite_diets', jsonEncode(favoriteDietNames));
    print('Diet favorite toggled: $dietName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xff92A3FD).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Recipes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _selectedTab == 0 ? const Color(0xff92A3FD) : Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xff92A3FD).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Diets',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _selectedTab == 1 ? const Color(0xff92A3FD) : Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedTab == 0
                  ? favoriteArticles.isEmpty
                  ? const Center(child: Text('No favorite recipes yet'))
                  : ListView.separated(
                itemCount: favoriteArticles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final article = favoriteArticles[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/articleDetail',
                        arguments: {
                          'id': article.id,
                          'title': article.title,
                          'content': article.content,
                          'date': article.date
                        }),
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
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.article, size: 50, color: Color(0xff92A3FD)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(article.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 16)),
                                const SizedBox(height: 5),
                                Text('Published on ${article.date}',
                                    style: const TextStyle(
                                        color: Color(0xff7B6F72),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _removeFavoriteArticle(article.id)),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : favoriteDiets.isEmpty
                  ? const Center(child: Text('No favorite diets yet'))
                  : ListView.separated(
                itemCount: favoriteDiets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final diet = favoriteDiets[index];
                  return Container(
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
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(diet.iconPath, width: 50, height: 50),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(diet.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 16)),
                              const SizedBox(height: 5),
                              Text('${diet.level} | ${diet.duration} | ${diet.calorie}',
                                  style: const TextStyle(
                                      color: Color(0xff7B6F72),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _toggleFavoriteDiet(diet.name)),
                      ],
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