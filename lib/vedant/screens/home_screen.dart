import 'package:cavista_app/screens/patientDash.dart';
import 'package:flutter/material.dart';
import 'health_queries_screen.dart';
import 'scheduled_requests_screen.dart';
import '../widgets/dashboard_button.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart'; // Import the Post class
import '../data/dummy_data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  // Change to StatefulWidget
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _accessToken;
  String? _username;
  String? _userRole;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _accessToken = prefs.getString('access_token');
        _username = prefs.getString('username');
        _userRole = prefs.getString('role');
        _userId = prefs.getString('user_id');
      });

      print('Access Token: $_accessToken'); // Debug print
      print('Username: $_username');
      print('User Role: $_userRole');
      print('User ID: $_userId');

      if (_accessToken != null) {
        await _fetchPosts();
      } else {
        // Handle not logged in state
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
        );
        // Navigate to login screen if needed
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> _fetchPosts() async {
    if (_accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view posts')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://cavista-backend-1.onrender.com/api/posts'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = json.decode(response.body);
        setState(() {
          _posts = postsJson.map((json) => Post.fromJson(json)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Handle token expiration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again')),
        );
        // Clear preferences and navigate to login
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        // Add navigation to login screen here
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts: $e')),
      );
    }
  }

  Widget _buildPostList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(child: Text('No posts available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PostCard(
            post: _posts[index],
            // accessToken: _accessToken ?? '',
            // username: _username ?? '',
            // userRole: _userRole ?? '',
            onReply: (String replyContent) async {
              // Handle reply functionality here
            },
          ),
        );
      },
    );
  }

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
      body: RefreshIndicator(
        onRefresh: _fetchPosts,
        child: SingleChildScrollView(
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PatientDashboard()));
                },
                child: Text("Fetch Posts"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
