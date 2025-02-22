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