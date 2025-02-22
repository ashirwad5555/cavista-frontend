import 'package:flutter/material.dart';
import '../widgets/request_card.dart';
import '../data/dummy_data.dart';

class ScheduledRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scheduled Requests"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: dummyRequests.length,
        itemBuilder: (context, index) {
          return RequestCard(request: dummyRequests[index]);
        },
      ),
    );
  }
}