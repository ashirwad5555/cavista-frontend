import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart'; // Import the Post and Comment classes
import '../data/dummy_data.dart';

class HealthQueriesScreen extends StatefulWidget {
  @override
  _HealthQueriesScreenState createState() => _HealthQueriesScreenState();
}

class _HealthQueriesScreenState extends State<HealthQueriesScreen> {
  final TextEditingController _replyController = TextEditingController();

  void _replyToPost(String postId) {
    final reply = _replyController.text.trim();
    if (reply.isNotEmpty) {
      setState(() {
        final post = dummyPosts.firstWhere((post) => post.id == postId);
        post.comments.add(
          Comment(
            id: DateTime.now().toString(),
            content: reply,
            authorName: "Dr. Smith",
            createdAt: DateTime.now(),
          ),
        );
      });
      _replyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Queries"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: dummyPosts[index],
            onReply: _replyToPost,
          );
        },
      ),
    );
  }
}