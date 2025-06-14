import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsmobile/api_service.dart';
import 'package:utsmobile/models/article_model.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final ApiService _apiService = ApiService();
  List<ArticleModel> articles = [];
  List<int> favoriteArticleIds = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _loadFavorites();
  }

  Future<void> _fetchArticles() async {
    try {
      final fetchedArticles = await _apiService.fetchArticles();
      setState(() {
        articles = fetchedArticles;
        isLoading = false;
      });
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = jsonEncode(fetchedArticles.map((e) => e.toJson()).toList());
      await prefs.setString('articles_cache', articlesJson);
      print('Articles cache saved: $articlesJson');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error fetching articles: $e');
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorite_articles');
    if (favoritesJson != null) {
      final List<dynamic> favoriteList = jsonDecode(favoritesJson);
      setState(() {
        favoriteArticleIds = favoriteList.cast<int>();
      });
      print('Favorite articles loaded: $favoriteArticleIds');
    }
  }

  Future<void> _toggleFavorite(int articleId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteArticleIds.contains(articleId)) {
        favoriteArticleIds.remove(articleId);
      } else {
        favoriteArticleIds.add(articleId);
      }
    });
    await prefs.setString('favorite_articles', jsonEncode(favoriteArticleIds));
    print('Favorite articles saved: $favoriteArticleIds');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Latest Recipes', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : articles.isEmpty
                  ? const Center(child: Text('No recipes found'))
                  : ListView.separated(
                itemCount: articles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final isFavorite = favoriteArticleIds.contains(article.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/articleDetail',
                          arguments: {
                            'id': article.id,
                            'title': article.title,
                            'content': article.content,
                            'date': article.date,
                          });
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
                          const Icon(Icons.article, size: 50, color: Color(0xff92A3FD)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(article.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16)),
                                const SizedBox(height: 5),
                                Text('Published on ${article.date}',
                                    style: const TextStyle(
                                        color: Color(0xff7B6F72), fontSize: 13, fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey),
                            onPressed: () => _toggleFavorite(article.id),
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