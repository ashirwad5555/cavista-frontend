import 'package:flutter/material.dart';
import '../models/post_model.dart'; // Import the Post class

class PostCard extends StatefulWidget {
  final Post post;
  final Function(String) onReply;

  PostCard({required this.post, required this.onReply});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _replyController = TextEditingController();
  bool _showReplyField = false;

  void _toggleReplyField() {
    setState(() {
      _showReplyField = !_showReplyField;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage("assets/user1.png"),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              widget.post.content,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            if (widget.post.images != null && widget.post.images!.isNotEmpty)
              Column(
                children: widget.post.images!
                    .map((image) => Image.asset("assets/user1.png"))
                    .toList(),
              ),
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, size: 20),
                  onPressed: () {
                    // Handle like
                  },
                ),
                Text(widget.post.verifiedCount.toString()),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.comment, size: 20),
                  onPressed: _toggleReplyField,
                ),
                Text(widget.post.comments.length.toString()),
              ],
            ),
            if (_showReplyField)
              Column(
                children: [
                  TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: "Write your reply...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onReply(widget.post.id);
                      _toggleReplyField();
                    },
                    child: Text("Reply"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            if (widget.post.comments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.post.comments.map((comment) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage("assets/user1.png"),
                              radius: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              comment.authorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          comment.content,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}