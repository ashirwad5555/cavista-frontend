import 'package:cavista_app/screens/doctor_Dash.dart';
import 'package:cavista_app/screens/patientDash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Add this for token storage

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isDoctor = false;
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _authData = {
    'name': '',
    'email': '',
    'phone': '',
    'password': '',
    'doctorId': '',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final baseUrl =
        'https://cavista-backend.onrender.com/api'; // Update with your server URL

    try {
      if (isLogin) {
        // Login API call
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _authData['email'],
            'password': _authData['password'],
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          // Store tokens
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', responseData['access_token']);
          await prefs.setString('refresh_token', responseData['refresh_token']);
          await prefs.setString('user_id', responseData['user']['id']);
          await prefs.setString(
              'username', responseData['user']['username']); // Add this line
          
          // Navigate based on user role
          final userResponse = await http.get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${responseData['access_token']}'
            },
          );

          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            if (isDoctor) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DoctorDash()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PatientDashboard()));
            }
          }
        } else {
          throw Exception(json.decode(response.body)['error']);
        }
      } else {
        // Signup API calls
        final signupEndpoint = isDoctor
            ? '$baseUrl/auth/register/doctor'
            : '$baseUrl/auth/register/patient';

        final signupData = {
          'username': _authData['name'],
          'email': _authData['email'],
          'mobno': _authData['phone'],
          'password': _authData['password'],
        };
        
        if (isDoctor) {
          signupData['verification_id'] = _authData['doctorId'];
        }

        final response = await http.post(
          Uri.parse(signupEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(signupData),
        );

        if (response.statusCode == 201) {
          // Show success message and switch to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Please login.')),
          );
          setState(() {
            isLogin = true;
          });
        } else {
          print(json.decode(response.body)['error']);
          throw Exception(json.decode(response.body)['error']);
        }
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              child: Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!isLogin)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) => _authData['name'] = value!,
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _authData['email'] = value!,
                ),
                if (!isLogin)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                    onSaved: (value) => _authData['phone'] = value!,
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _authData['password'] = value!,
                ),
                if (!isLogin && isDoctor)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Doctor ID'),
                    validator: (value) {
                      if (isDoctor && (value == null || value.isEmpty)) {
                        return 'Please enter Doctor ID';
                      }
                      return null;
                    },
                    onSaved: (value) => _authData['doctorId'] = value!,
                  ),
                SwitchListTile(
                  title: Text('Register as Doctor'),
                  value: isDoctor,
                  onChanged: (value) {
                    setState(() {
                      isDoctor = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isLogin ? 'LOGIN' : 'SIGN UP'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin ? 'Create new account' : 'Already have an account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}