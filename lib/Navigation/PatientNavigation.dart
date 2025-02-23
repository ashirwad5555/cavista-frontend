import 'package:cavista_app/screens/PatientProfile.dart';
import 'package:cavista_app/siddhesh/BookAppointment.dart';
import 'package:cavista_app/siddhesh/news.dart';
import 'package:flutter/material.dart';
import 'package:cavista_app/screens/patientDash.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import other screens when created
// import 'package:cavista_app/screens/patient_consult.dart';
// import 'package:cavista_app/screens/patient_profile.dart';

class PatientNavigation extends StatefulWidget {
  @override
  _PatientNavigationState createState() => _PatientNavigationState();
}

class _PatientNavigationState extends State<PatientNavigation> {
  int _selectedIndex = 0;

  String access_token = "";
  String patient_id = "";
  late List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    _loadPrefs();
    // _initializeScreens();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      access_token = prefs.getString('access_token') ?? "";
      patient_id = prefs.getString('user_id') ?? "";
      _initializeScreens();
    });
  }

  void _initializeScreens() {
    _screens = [
      PatientDashboard(),
      NewsApp(),
      BookAppointmentPage(
        accessToken: access_token,
        patientId: patient_id,
      ),
      PatientProfile(),
    ];
  }
  // // You'll need to create these screens
  // final List<Widget> _screens = [
  //   PatientDashboard(), // Home screen
  //   BookAppointmentPage(accessToken: access_token,patientId: patient_id ), // Replace with actual Consult screen
  //   Center(child: Text('Profile Screen')), // Replace with actual Profile screen
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Awareness',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Consult',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          elevation: 0,
        ),
      ),
    );
  }
}
