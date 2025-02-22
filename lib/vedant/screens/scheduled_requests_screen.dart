import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/request_card.dart';
import 'package:intl/intl.dart';

class Notification {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String patientMobile;
  final String date;
  final String time;
  final String message;
  final String status;

  Notification({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.patientMobile,
    required this.date,
    required this.time,
    required this.message,
    required this.status,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      patientName: json['patient_name'] ?? 'Unknown',
      patientMobile: json['patient_mobile'] ?? 'N/A',
      date: json['date'] ?? 'N/A',
      time: json['time'] ?? 'N/A',
      message: json['message'] ?? 'No message',
      status: json['status'] ?? 'pending',
    );
  }
}

class ScheduledRequestsScreen extends StatefulWidget {
  @override
  _ScheduledRequestsScreenState createState() =>
      _ScheduledRequestsScreenState();
}

class _ScheduledRequestsScreenState extends State<ScheduledRequestsScreen> {
  List<Notification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getString('user_id');
      final accessToken = prefs.getString('access_token');

      if (doctorId == null || accessToken == null) {
        setState(() {
          _error = 'Please login again';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://web-production-6a63.up.railway.app/api/notifications/doctor/$doctorId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['notifications'] as List)
            .map((item) => Notification.fromJson(item))
            .toList();

        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _respondToRequest(Notification notification) async {
    selectedDate = null;
    selectedTime = null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Schedule Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(selectedDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(selectedTime == null
                        ? 'Select Time'
                        : selectedTime!.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedDate != null && selectedTime != null)
                      ? () async {
                          Navigator.of(context).pop();
                          await _sendResponse(notification);
                        }
                      : null,
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendResponse(Notification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorUsername = prefs.getString('username');
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('Please login again');
      }

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final formattedTime = selectedTime!.format(context);
      final message =
          'Dr. $doctorUsername is ready to meet at $formattedDate $formattedTime';

      final response = await http.post(
        Uri.parse(
            'https://cavista-backend-1.onrender.com/api/notifications/doctor'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': notification.patientId,
          'doctor_id': notification.doctorId,
          'message': message,
          'expected_date': formattedDate,
          'expected_time': formattedTime,
          'status': 'accepted' // Add this line
        }),
      );

      if (response.statusCode == 201) {

        // Update local state
        setState(() {
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = Notification(
                id: notification.id,
                patientId: notification.patientId,
                doctorId: notification.doctorId,
                patientName: notification.patientName,
                patientMobile: notification.patientMobile,
                date: formattedDate,
                time: formattedTime,
                message: message,
                status: 'accepted');
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment scheduled successfully')),
        );
        _fetchNotifications(); // Refresh the list
      } else {
        throw Exception('Failed to schedule appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Requests'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(child: Text('No scheduled requests'))
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(
                                notification.patientName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text('📱 ${notification.patientMobile}'),
                                  Text('📅 ${notification.date}'),
                                  Text('⏰ ${notification.time}'),
                                  Text('💬 ${notification.message}'),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: notification.status == 'pending'
                                    ? () => _respondToRequest(notification)
                                    : null,
                                child: Chip(
                                  label: Text(
                                    notification.status.toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      notification.status == 'pending'
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
