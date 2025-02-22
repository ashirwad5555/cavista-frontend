import 'package:flutter/material.dart';
import 'package:cavista_app/modules/Post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostCard extends StatelessWidget {
  final Post post;
  final String? username;
  final String? accessToken;

  const PostCard({
    Key? key,
    required this.post,
    this.username,
    this.accessToken,
  }) : super(key: key);

  String _formatDate(Map<String, String> dateMap) {
    if (dateMap['\$date'] != null) {
      final date = DateTime.parse(dateMap['\$date']!);
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'No date';
  }

  Future<void> _addComment(BuildContext context, String content) async {
    if (accessToken == null || username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a comment')),
      );
      return;
    }

    try {
      
      print('Adding comment with:');
      print('Post ID: ${post.id}');
      print('Content: $content');
      print('Username: $username');

      final response = await http.post(
        Uri.parse('https://cavista-backend-1.onrender.com/api/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'post_id': post.id,
          'username': username,
          'content': content,
        }),
      );

      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again to add a comment')),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to add comment');
      }
    } catch (e) {
      print('Error adding comment: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(post.authorName[0].toUpperCase()),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            title: Text(post.authorName),
            subtitle: Text(_formatDate(post.createdAt)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified,
                    color: post.verifiedCount > 0 ? Colors.blue : Colors.grey),
                const SizedBox(width: 4),
                Text('${post.verifiedCount}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (post.images != null && post.images!.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        post.images![index],
                        fit: BoxFit.cover,
                        width: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error_outline),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: Text('Verify (${post.verifiedCount})'),
                  onPressed: () {
                    // here verify functionality
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('Comments (${post.comments.length})'),
                  onPressed: () {
                    _showCommentsDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(BuildContext context) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              height: 200,
              child: FutureBuilder<http.Response>(
                future: http.get(
                  Uri.parse(
                      'https://cavista-backend-1.onrender.com/api/comments/${post.id}'),
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                  },
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No comments yet'));
                  }

                  final commentsData = json.decode(snapshot.data!.body);
                  final comments = (commentsData['comments'] as List)
                      .map((comment) => Comment.fromJson(comment))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment.username),
                        subtitle: Text(comment.content),
                        trailing: Text(
                          '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.isNotEmpty) {
                await _addComment(context, commentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Comment'),
          ),
        ],
      ),
    );
  }
}
