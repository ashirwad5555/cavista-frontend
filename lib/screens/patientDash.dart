import 'package:cavista_app/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:cavista_app/modules/Post.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cavista_app/modules/Post.dart';
import 'dart:io';
import 'dart:convert';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _accessToken;
  String? _username;
  List<String> images = [];
  List<String> imageNames = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndUsername();
  }

  Future<void> _loadTokenAndUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _username = prefs.getString('username');
    });

     print('Access Token: $_accessToken'); // Debug log
    print('Username: $_username'); // Debug log
    
    _fetchPosts();
    setState(() {});
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
        Uri.parse('https://cavista-backend.onrender.com/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> postsJson = json.decode(response.body);
        setState(() {
          _posts = postsJson.map((json) => Post.fromJson(json)).toList();
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized access
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
        // Optionally navigate to login screen
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> imageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _createPost(String content, List<String>? imagePaths) async {
    if (_accessToken == null || _username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated. Please login again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<String> base64Images = [];
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (String path in imagePaths) {
          try {
            String base64Image = await imageToBase64(path);
            base64Images.add(base64Image);
          } catch (e) {
            print('Error converting image to base64: $e');
            continue;
          }
        }
      }

      final response = await http.post(
        Uri.parse('https://cavista-backend.onrender.com/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'content': content,
          'authorName': _username,
          'images': imagePaths ?? [],
          'comments': [],
          'verifiedCount': 0,
        }),
      );

      if (response.statusCode == 201) {
        await _fetchPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          images = pickedFiles.map((file) => file.path).toList();
          imageNames = pickedFiles.map((file) => file.name).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return PostCard(post: post);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final textController = TextEditingController();
    List<String> images = [];
    List<String> imageNames = [];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Post Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
                onPressed: () async {
                  await _pickImages();
                  setState(() {}); // Refresh the UI to show selected images
                },
              ),
              if (imageNames.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selected Images:'),
                      ...imageNames.map((name) => Text('• $name')),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                Navigator.pop(context);
                await _createPost(
                    textController.text, images.isEmpty ? null : images);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
