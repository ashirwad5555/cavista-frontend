import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final String name;
  final bool isAI;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.name,
    this.isAI = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isAI ? Colors.blue[100] : Colors.green[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(message),
          ],
        ),
      ),
    );
  }
}
