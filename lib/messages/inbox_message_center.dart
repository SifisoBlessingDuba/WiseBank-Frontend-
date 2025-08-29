import 'package:flutter/material.dart';
import 'notification_settings.dart'; // Added import
import 'chat_bot.dart'; // Added import

class InboxMessageCenterScreen extends StatelessWidget {
  const InboxMessageCenterScreen({super.key});

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
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Transactions
          _buildSectionHeader(context, 'Transactions'),
          ListTile(
            title: const Text('MyUpdates Message'),
            trailing: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '4', // Example unread count
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open MyUpdates Message Details')),
              );
            },
          ),
          const Divider(),

          // Chat with Us Button/Banner
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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

          // Section 2: All messages
          _buildSectionHeader(context, 'All Messages'),
          _buildMessageItem(
            context,
            title: 'Just for you',
            subtitle: 'Personalized offers',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Personalized Offers')),
              );
            },
          ),
          _buildMessageItem(
            context,
            title: 'Anti-Fraud and Security',
            subtitle: 'Security tips',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Security Tips')),
              );
            },
          ),
          _buildMessageItem(
            context,
            title: 'Authenticate',
            subtitle: 'Login/session confirmations',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Authentication Messages')),
              );
            },
          ),
          _buildMessageItem(
            context,
            title: 'What’s New?',
            subtitle: 'Product updates',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Product Updates')),
              );
            },
          ),
          _buildMessageItem(
            context,
            title: 'Banking App News',
            subtitle: 'Financial news/savings advice',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Banking App News')),
              );
            },
          ),
          _buildMessageItem(
            context,
            title: 'Instant Money Vouchers',
            subtitle: 'Cash voucher notices',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open Instant Money Vouchers')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, {required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
