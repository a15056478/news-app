import 'package:weather/model/source_model.dart';

class ArticalModel {
  SourceModel source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  ArticalModel(
      {this.source,
      this.author,
      this.content,
      this.description,
      this.publishedAt,
      this.title,
      this.url,
      this.urlToImage});

  // Mapping json to list
  factory ArticalModel.fromJson(Map<String, dynamic> json) {
    return ArticalModel(
        author: json['author'] as String,
        content: json['content'] as String,
        description: json['description'] as String,
        publishedAt: json['publishedAt'] as String,
        source: SourceModel.fromJson(json['source']),
        title: json['title'] as String,
        url: json['url'] as String,
        urlToImage: json['urlToImage'] as String);
  }
}
