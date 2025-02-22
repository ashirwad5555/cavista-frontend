import 'package:cavista_app/modules/Post.dart';

class Post {
  final String id;
  final String content;
  final String authorName;
  final List<String>? images;
  final List<Comment> comments;
  final int verifiedCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    required this.authorName,
    this.images,
    required this.comments,
    required this.verifiedCount,
    required this.createdAt,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '', // Provide default empty string if null
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? 'Unknown',
      images: (json['images'] as List?)
              ?.map((img) => img as String)
              .toList(),
      comments: json['comments'] ?? [],
      verifiedCount: json['verifiedCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }

}

class Comment {
  final String id;
  final String content;
  final String authorName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });
}