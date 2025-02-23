import 'package:cavista_app/Navigation/PatientNavigation.dart';
import 'package:cavista_app/screens/doctor_Dash.dart';
import 'package:cavista_app/screens/patientDash.dart';
import 'package:cavista_app/vedant/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isDoctor = false;
  bool _obscurePassword = true;
  bool _isLoading = false; // Add this line
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

    setState(() {
      _isLoading = true; // Set loading to true when submission starts
    });

    final baseUrl = 'https://cavista-backend-1.onrender.com/api';
    try {
      if (isLogin) {
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
          print("responseData is   ${responseData}");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', responseData['access_token']);
          await prefs.setString('refresh_token', responseData['refresh_token']);
          await prefs.setString(
              'user_id', responseData['user']['id'].toString());
          await prefs.setString('username', responseData['user']['username']);
          await prefs.setString(
              'role', responseData['user']['role']); // Store user role

          // Print for debugging
          print('User ID: ${responseData['user']['id'].toString()}');

          final userResponse = await http.get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${responseData['access_token']}'
            },
          );

          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            if (responseData['user']['role'] == 'doctor') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PatientNavigation()));
            }
          }
        } else {
          throw Exception(json.decode(response.body)['error']);
        }
      } else {
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
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isLogin ? 'Welcome Back' : 'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 24),
                          if (!isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              onSaved: (value) => _authData['name'] = value!,
                            ),
                          if (!isLogin) const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (value) => _authData['email'] = value!,
                          ),
                          const SizedBox(height: 16),
                          if (!isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.length < 10) {
                                  return 'Invalid phone number';
                                }
                                return null;
                              },
                              onSaved: (value) => _authData['phone'] = value!,
                            ),
                          if (!isLogin) const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) => _authData['password'] = value!,
                          ),
                          const SizedBox(height: 16),
                          if (!isLogin && isDoctor)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Doctor ID',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (isDoctor &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter Doctor ID';
                                }
                                return null;
                              },
                              onSaved: (value) =>
                                  _authData['doctorId'] = value!,
                            ),
                          if (!isLogin && isDoctor) const SizedBox(height: 16),
                          if (!isLogin)
                            Card(
                              elevation: 0,
                              color: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  'Register as Doctor',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                value: isDoctor,
                                onChanged: (value) {
                                  setState(() {
                                    isDoctor = value;
                                  });
                                },
                                secondary: Icon(
                                  Icons.medical_services_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isLogin ? 'LOGIN' : 'SIGN UP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? 'Don\'t have an account? Sign Up'
                                  : 'Already have an account? Login',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
