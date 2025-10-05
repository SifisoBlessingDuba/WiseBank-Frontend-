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