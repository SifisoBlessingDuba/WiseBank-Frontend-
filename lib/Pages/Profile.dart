import 'package:flutter/material.dart';
import 'package:wisebank_frontend/Pages/notifications.dart';
import '../messages/inbox_message_center.dart';
import 'personal-infomation.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'cards.dart';
import '../services/globals.dart';
import 'package:wisebank_frontend/services/api_service.dart';
import 'package:wisebank_frontend/services/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String fullName = "User";
  String email = "user@example.com";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (loggedInUserId.isEmpty) return;

    try {
      final api = ApiService();
      final Map<String, dynamic> data = await api.getUserDetails(loggedInUserId);
      setState(() {
        fullName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        email = data['email'] ?? "";
      });
    } catch (e) {
      print("fetchUserData (ApiService) error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Using Card for modern design
            buildProfileCard(
              context,
              icon: Icons.person,
              title: "Personal Information",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalInformation()),
                );
              },
            ),
            buildProfileCard(
              context,
              icon: Icons.add_card_outlined,
              title: "Banks and Cards",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardsPage()),
                );
              },
            ),
            buildProfileCard(
              context,
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()),
                );
              },
            ),
            buildProfileCard(
              context,
              icon: Icons.chat_bubble_rounded,
              title: "Message",
              onTap: () { // Modified this onTap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InboxMessageCenterScreen()),
                );
              },
            ),
            buildProfileCard(
              context,
              icon: Icons.settings,
              title: "Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()),
                );
              },
            ),
            buildProfileCard(
              context,
              icon: Icons.output,
              title: "Sign Out",
              onTap: () async {
                // Attempt remote logout and clear local token
                await AuthService.instance.logout(remote: true);
                // Navigate to login and clear navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileCard(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
