import 'package:flutter/material.dart';
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

  void fetchNotifications() async {
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