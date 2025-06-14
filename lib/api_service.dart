import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsmobile/models/article_model.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<ArticleModel>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search.php?s=chicken')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];
        final List<ArticleModel> articles = meals.map((json) => ArticleModel.fromJson(json)).toList();
        final prefs = await SharedPreferences.getInstance();
        final articlesJson = jsonEncode(articles.map((e) => e.toJson()).toList());
        await prefs.setString('articles_cache', articlesJson);
        print('Articles cache saved in ApiService: $articlesJson');
        return articles;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }
}