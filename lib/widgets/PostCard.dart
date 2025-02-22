import 'package:flutter/material.dart';
import 'package:cavista_app/modules/Post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  String _formatDate(Map<String, String> dateMap) {
    if (dateMap['\$date'] != null) {
      final date = DateTime.parse(dateMap['\$date']!);
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'No date';
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
                    // TODO: Implement verify functionality
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: post.comments.length,
            itemBuilder: (context, index) {
              final comment = post.comments[index];
              return ListTile(
                title: Text(comment.authorName),
                subtitle: Text(comment.content),
                trailing: Text(_formatDate(comment.createdAt as Map<String, String>)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
