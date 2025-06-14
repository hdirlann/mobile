class ArticleModel {
  final int id;
  final String title;
  final String content;
  final String date;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: int.parse(json['idMeal'] ?? '0'),
      title: json['strMeal'] ?? 'No Title',
      content: json['strInstructions'] ?? 'No Content',
      date: json['dateModified'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id.toString(),
      'strMeal': title,
      'strInstructions': content,
      'dateModified': date,
    };
  }
}