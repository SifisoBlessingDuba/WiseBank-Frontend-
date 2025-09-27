import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import 'message_detail_screen.dart';
import 'notification_settings.dart';
import 'chat_bot.dart';

class InboxMessageCenterScreen extends StatefulWidget {
  const InboxMessageCenterScreen({super.key});

  @override
  State<InboxMessageCenterScreen> createState() =>
      _InboxMessageCenterScreenState();
}

class _InboxMessageCenterScreenState extends State<InboxMessageCenterScreen> {
  late Future<List<Message>> _messagesFuture;
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _messagesFuture = _messageService.getAllMessages(); // fetch all messages
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _messagesFuture = _messageService.getAllMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Centre"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Message>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final messages = snapshot.data;
          if (messages == null || messages.isEmpty) {
            return const Center(child: Text("No messages available"));
          }

          return RefreshIndicator(
            onRefresh: _refreshMessages,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text("Message #${msg.messageId}"),
                  subtitle: Text(
                    msg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessageDetailScreen(
                        title: "Message #${msg.messageId}",
                        content: msg.content,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatBotScreen()),
        ),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}
