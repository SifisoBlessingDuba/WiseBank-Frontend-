import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Sample notification data
  final List<Map<String, dynamic>> notifications = [
    {"id": 1, "message": "Your payment of R50 was successful.", "date": "28-Aug-2025 14:30", "read": false},
    {"id": 2, "message": "New deposit of R2000 received.", "date": "27-Aug-2025 09:15", "read": true},
    {"id": 3, "message": "Low balance alert: R10 remaining.", "date": "26-Aug-2025 18:45", "read": false},
    {"id": 4, "message": "Bill payment of R120 completed.", "date": "25-Aug-2025 10:00", "read": true},
    {"id": 5, "message": "Transfer to John Doe: R300.", "date": "24-Aug-2025 13:20", "read": false},
    {"id": 6, "message": "Interest credited: R45.50.", "date": "23-Aug-2025 08:50", "read": true},
    {"id": 7, "message": "New account statement available.", "date": "22-Aug-2025 16:10", "read": false},
    {"id": 8, "message": "Withdrawal of R500 processed.", "date": "21-Aug-2025 11:30", "read": true},
    {"id": 9, "message": "Account upgrade approved.", "date": "18-Aug-2025 15:25", "read": false},
    {"id": 10, "message": "Transaction dispute filed.", "date": "16-Aug-2025 10:50", "read": true},
    {"id": 11, "message": "Security alert detected.", "date": "14-Aug-2025 13:40", "read": false},
    {"id": 12, "message": "Payment reminder: R75 due.", "date": "20-Jul-2025 14:00", "read": true},
    {"id": 13, "message": "Deposit of R1500 confirmed.", "date": "19-Jul-2025 09:45", "read": false},
    {"id": 14, "message": "Overdraft limit increased.", "date": "17-Jul-2025 12:15", "read": true},
    {"id": 15, "message": "Stipend payment due: R200.", "date": "15-Jul-2025 17:30", "read": false},
  ];
  final NotificationService api = NotificationService();
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {

    super.initState();
    fetchNotifications();
  }

  // Fetch all notifications from Spring Boot backend
  Future<void> fetchNotifications() async {
    try {
      final url = Uri.parse('$apiBaseUrl/notification/find-all');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          notifications = jsonList.map((json) => NotificationModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() => isLoading = false);

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  void getAllNotifications() async {
    try {
      final data = await api.getAllNotifications();
      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              color: notification["read"] ? Colors.grey[200] : Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: notification["read"] ? Colors.grey : Colors.blue,
                ),
                title: Text(notification["message"]),
                subtitle: Text(notification["date"]),
                trailing: notification["read"] ? const Text("Read") : const Text("New"),
              ),
            );
          },
        ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final read = notification.isRead; // already a bool, no toLowerCase()
          return Card(
            color: read ? Colors.grey[200] : Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.notifications,
                color: read ? Colors.grey : Colors.blue,
              ),
              title: Text(notification.message),
              subtitle: Text(
                '${notification.timeStamp.day}-${notification.timeStamp.month}-${notification.timeStamp.year} '
                    '${notification.timeStamp.hour}:${notification.timeStamp.minute}',
              ),
              trailing: read ? const Text("Read") : const Text("New"),
            ),
          );
        },
      ),
    );
  }
}