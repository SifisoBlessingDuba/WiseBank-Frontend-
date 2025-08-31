import 'package:flutter/material.dart';
import 'message_detail_screen.dart'; // Ensure this file exists and is correct
import 'notification_settings.dart'; // Ensure this file exists
import 'chat_bot.dart';             // Ensure this file exists

class InboxMessageCenterScreen extends StatefulWidget {
  const InboxMessageCenterScreen({super.key});

  @override
  State<InboxMessageCenterScreen> createState() => _InboxMessageCenterScreenState();
}

class _InboxMessageCenterScreenState extends State<InboxMessageCenterScreen> {
  // A map to hold predefined content for each message
  final Map<String, String> _messageContents = {
    'MyUpdates Message': 'Here are your latest updates regarding transactions, account activity, and important notifications.',
    'Just for you': 'Content for Just for you: Check out these personalized offers we think you\'ll love!',
    'Anti-Fraud and Security': 'Content for Anti-Fraud and Security: Learn how to protect your account with our latest security tips.',
    'Authenticate': 'Content for Authenticate: Recent login and session confirmation details will appear here.',
    'What’s New?': 'Content for What’s New?: Discover the latest features and updates to our banking app.',
    'Banking App News': 'Content for Banking App News: Stay informed with the latest financial news and savings advice.',
    'Instant Money Vouchers': 'Content for Instant Money Vouchers: Details about your active and redeemed cash vouchers.',
  };

  // Helper to build individual message list items
  Widget _buildMessageItem(BuildContext context, {required String title, String? subtitle}) {
    final String content = _messageContents[title] ?? 'No content available for $title.';
    
    return ListTile(
      title: Text(title), 
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right), 
      onTap: () {
        print('Navigating to detail for: $title'); 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailScreen(
              title: title,
              content: content,
            ),
          ),
        );
      },
    );
  }

  // Helper to build section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.inbox),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          tooltip: 'Inbox/Back',
        ),
        title: const Text('Message Centre'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Transactions'),
          Padding( 
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: const Text('MyUpdates Message'),
              trailing: const Icon(Icons.chevron_right), 
              onTap: () {
                final String title = 'MyUpdates Message';
                final String content = _messageContents[title]!;
                print('Navigating to detail for: $title'); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageDetailScreen(
                      title: title,
                      content: content,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.all(16.0), 
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat with Us'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          _buildSectionHeader(context, 'All Messages'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildMessageItem(context, title: 'Just for you', subtitle: 'Personalized offers'),
                _buildMessageItem(context, title: 'Anti-Fraud and Security', subtitle: 'Security tips'),
                _buildMessageItem(context, title: 'Authenticate', subtitle: 'Login/session confirmations'),
                _buildMessageItem(context, title: 'What’s New?', subtitle: 'Product updates'),
                _buildMessageItem(context, title: 'Banking App News', subtitle: 'Financial news/savings advice'),
                _buildMessageItem(context, title: 'Instant Money Vouchers', subtitle: 'Cash voucher notices'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
