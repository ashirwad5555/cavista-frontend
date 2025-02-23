import 'dart:convert';

import 'package:flutter/material.dart';
import 'messageCard.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Widget> list = [];
  final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCorK5GW4OXnCQ6QRqsJJGrY0tU8appaLM';

  final header = {
    'Content-Type': 'application/json',
  };

  List<String> healthQuestions = [
    "What symptoms are you experiencing?",
    "How long have you been experiencing these symptoms?",
    "Do you have any known allergies?",
    "Are you currently taking any medications?",
    "Do you have any chronic conditions?",
  ];

  int currentQuestionIndex = 0;
  Map<String, String> userResponses = {};

  void onSend() async {
    if (_controller.text.isEmpty) return;

    ChatMessage userMessage = ChatMessage(
      message: _controller.text,
      name: widget.name,
    );
    setState(() {
      list.insert(0, userMessage);
    });

    userResponses[healthQuestions[currentQuestionIndex]] = _controller.text;

    _controller.clear();

    if (currentQuestionIndex < healthQuestions.length - 1) {
      currentQuestionIndex++;

      ChatMessage nextQuestion = ChatMessage(
        isAI: true,
        message: healthQuestions[currentQuestionIndex],
        name: 'Healthcare Bot',
      );
      setState(() {
        list.insert(0, nextQuestion);
      });
    } else {

      String userInput = userResponses.values.join(" ");
      var data = {
        "contents": [
          {
            "parts": [
              {"text": "Based on the following symptoms and information, what could be the possible health condition and what should be the next steps? Symptoms and info: $userInput"}
            ]
          }
        ]
      };

      await http
          .post(Uri.parse(url), headers: header, body: jsonEncode(data))
          .then((value) {
        if (value.statusCode == 200) {
          var result = jsonDecode(value.body);
          String responseText = result['candidates'][0]['content']['parts'][0]['text'];

          ChatMessage botResponse = ChatMessage(
            isAI: true,
            message: responseText,
            name: 'Healthcare Bot',
          );
          setState(() {
            list.insert(0, botResponse);
          });
        } else {
          print("error occurred");
        }
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ChatMessage firstQuestion = ChatMessage(
      isAI: true,
      message: healthQuestions[currentQuestionIndex],
      name: 'Healthcare Bot',
    );
    setState(() {
      list.insert(0, firstQuestion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Hey ${widget.name}! How can I help you?"),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        backgroundColor: Colors.blue[50],
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => list[index],
                itemCount: list.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          onSubmitted: (value) => onSend(),
                          decoration: InputDecoration.collapsed(
                            hintText: "Write your response here",
                            hintStyle: TextStyle(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSend,
                    icon: Icon(Icons.send),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}