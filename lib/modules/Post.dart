class Post {
  final String id;
  final String content;
  final String authorName;
  final List<String>? images;
  final Map<String, String> createdAt;
  final List<Comment> comments;
  final int verifiedCount;

  Post({
    required this.id,
    required this.content,
    required this.authorName,
    this.images,
    required this.createdAt,
    required this.comments,
    required this.verifiedCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String dateStr;
    final createdAt = json['createdAt'];
    if (createdAt is Map && createdAt['\$date'] != null) {
      // Handle MongoDB ISODate format
      dateStr = createdAt['\$date'];
    } else {
      dateStr = DateTime.now().toIso8601String();
    }

    return Post(
      id: json['_id'] is Map ? json['_id']['\$oid'] : json['_id'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: {'\$date': dateStr}, // Store the original ISO date string
      comments: json['comments'] != null
          ? List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x)))
          : [],
      verifiedCount: json['verifiedCount'] ?? 0,
    );
  }
}

class Comment {
  final String content;
  final String authorName;
  final DateTime createdAt;

  Comment({
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    String dateStr;
    final createdAt = json['createdAt'];
    if (createdAt is Map && createdAt['\$date'] != null) {
      dateStr = createdAt['\$date'];
    } else {
      dateStr = DateTime.now().toIso8601String();
    }

    return Comment(
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: DateTime.parse(dateStr),
    );
  }
}
