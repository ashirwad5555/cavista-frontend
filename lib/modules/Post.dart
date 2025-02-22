class PostImage {
  final String fileId;
  final String url;

  PostImage({required this.fileId, required this.url});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      fileId: json['file_id'],
      url: json['url'],
    );
  }
}

class Post {
  final String id;
  final String content;
  final String authorName;
  final List<PostImage> images;
  final List<dynamic> comments;
  final int verifiedCount;
  final String createdAt;

  Post({
    required this.id,
    required this.content,
    required this.authorName,
    required this.images,
    required this.comments,
    required this.verifiedCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      content: json['content'],
      authorName: json['authorName'],
      images: (json['images'] as List)
          .map((img) => PostImage.fromJson(img))
          .toList(),
      comments: json['comments'] ?? [],
      verifiedCount: json['verifiedCount'] ?? 0,
      createdAt: json['createdAt'],
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      replies: json['replies'] != null
          ? List<Reply>.from(json['replies'].map((x) => Reply.fromJson(x)))
          : [],
    );
  }
}

class Reply {
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;

  Reply({
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
