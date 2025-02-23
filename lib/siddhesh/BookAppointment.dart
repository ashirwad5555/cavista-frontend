import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final String patientId;
  final String accessToken;
  const BookAppointmentPage(
      {Key? key, required this.patientId, required this.accessToken})
      : super(key: key);

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<Map<String, String>> _doctors = [];
  Map<String, Map<String, dynamic>> _acceptedAppointments = {};
  Set<String> _requestedDoctors = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? patientId = prefs.getString('user_id');

      if (patientId == null) {
        _showSnackBar('Error: Patient ID not found');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://cavista-backend-1.onrender.com/api/notifications/patient/$patientId'),
        headers: {
          "Authorization": "Bearer ${widget.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications = data['notifications'] as List;

        setState(() {
          _acceptedAppointments.clear();
          for (var notification in notifications) {
            final doctorId = notification['doctor_id'];
            if (doctorId != null) {
              _requestedDoctors.add(doctorId);

              // Store accepted appointment details
              if (notification['expected_date'] != null &&
                  notification['expected_time'] != null) {
                _acceptedAppointments[doctorId] = {
                  'doctor_name': notification['doctor_name'],
                  'date': notification['expected_date'],
                  'time': notification['expected_time'],
                  'message': notification['message']
                };
              }
            }
          }
        });
      } else {
        _showSnackBar('Failed to load notifications');
      }
    } catch (e) {
      _showSnackBar('Error loading notifications: $e');
    }
  }

  Future<void> _fetchDoctors() async {
    final String apiUrl =
        'https://cavista-backend-1.onrender.com/api/doctors';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _doctors = data.map((doctor) {
            return {
              'id': doctor['id'].toString(),
              'name': doctor['name']?.toString() ?? 'Unknown',
              'specialization':
                  doctor['specialization']?.toString() ?? 'General Physician',
              'availability': doctor['availability']?.toString() ?? 'Mon-Fri',
            };
          }).toList();
        });
      } else {
        _showSnackBar('Failed to load doctors');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Widget _buildAppointmentStatus(String doctorId) {
    final appointment = _acceptedAppointments[doctorId];
    if (appointment != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Appointment Confirmed',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${appointment['date']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Time: ${appointment['time']}',
              style: const TextStyle(fontSize: 14),
            ),
            if (appointment['message'] != null)
              Text(
                'Note: ${appointment['message']}',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: _requestedDoctors.contains(doctorId)
          ? null
          : () => _sendRequest(doctorId),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: _requestedDoctors.contains(doctorId)
            ? Colors.grey[300]
            : Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_requestedDoctors.contains(doctorId))
            const Icon(Icons.access_time, size: 20),
          if (_requestedDoctors.contains(doctorId)) const SizedBox(width: 8),
          Text(
            _requestedDoctors.contains(doctorId)
                ? 'Request Pending'
                : 'Request Appointment',
            style: TextStyle(
              fontSize: 16,
              color: _requestedDoctors.contains(doctorId)
                  ? Colors.grey[700]
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: const Text(
              'Select a doctor to request an appointment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetchDoctors();
                await _fetchNotifications();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                child: Text(
                                  doctor['name']?[0] ?? 'D',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor['specialization'] ??
                                          'General Physician',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                doctor['availability'] ?? 'Mon-Fri',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAppointmentStatus(doctor['id']!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendRequest(String doctorId) async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? patientId = prefs.getString('user_id');

      if (patientId == null) {
        _showSnackBar('Error: Patient ID not found');
        return;
      }

      final response = await http.post(
        Uri.parse(
            'https://cavista-backend-1.onrender.com/api/notifications/patient'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.accessToken}",
        },
        body: jsonEncode({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'message':
              "${prefs.getString('username')} wants to take an appointment",
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _requestedDoctors.add(doctorId);
        });
        _showSnackBar('Appointment request sent successfully');
      } else {
        _showSnackBar('Failed to send request');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
