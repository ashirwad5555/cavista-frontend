import '../models/post_model.dart'; // Import the Post and Comment classes

List<Post> dummyPosts = [
  Post(
    id: "1",
    content: "What are the best practices for managing diabetes at home?",
    authorName: "Vedant Takalkar",
    images: ["user1.png"],
    comments: [
      Comment(
        id: "1",
        content: "Regular exercise and a balanced diet are key.",
        authorName: "Dr. Smith",
        createdAt: DateTime(2023, 10, 10),
      ),
    ],
    verifiedCount: 12,
    createdAt: DateTime(2023, 10, 9),
  ),
  // Add more posts
];

class Request {
  final String id;
  final String patientName;
  final String reason;
  final DateTime date;
  final String time;

  Request({
    required this.id,
    required this.patientName,
    required this.reason,
    required this.date,
    required this.time,
  });
}

List<Request> dummyRequests = [
  Request(
    id: "1",
    patientName: "Siddhesh More",
    reason: "Routine checkup",
    date: DateTime(2023, 10, 15),
    time: "10:00 AM",
  ),
  // Add more requests
];