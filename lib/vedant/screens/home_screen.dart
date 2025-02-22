import 'package:flutter/material.dart';
import 'health_queries_screen.dart';
import 'scheduled_requests_screen.dart';
import '../widgets/dashboard_button.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart'; // Import the Post class
import '../data/dummy_data.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DashboardButton(
                    icon: Icons.medical_services,
                    label: "Health Queries",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthQueriesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DashboardButton(
                    icon: Icons.calendar_today,
                    label: "Scheduled Requests",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduledRequestsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "General Posts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dummyPosts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: dummyPosts[index],
                  onReply: (postId) {
                    // Handle reply functionality for general posts
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}