import 'package:flutter/material.dart';
import 'Profile.dart';
import 'change_password_page.dart';
import 'dashboard.dart';
import 'cards.dart';
import 'transaction.dart';
import 'contact_us_page.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back arrow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(title: 'Language', subtitle: 'English'),
            _buildSettingItem(
              title: 'My Profile',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
            _buildSettingItem(
              title: 'Contact Us',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsPage()),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(
              title: 'Change Password',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage()),
                );
              },
            ),
            _buildSettingItem(
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              'Choose what data you share with us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingItem(title: 'Biometric'),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Settings tab selected
        onTap: (index) {
          _navigateFromBottomNav(index, context);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _navigateFromBottomNav(int index, BuildContext context) {
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      case 1: // Card
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardsPage()),
        );
        break;
      case 2: // Transactions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransactionPage()),
        );
        break;
      case 3: // Settings (current page)
        // Already on Settings page, do nothing
        break;
    }
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap ?? () {},
    );
  }
}
