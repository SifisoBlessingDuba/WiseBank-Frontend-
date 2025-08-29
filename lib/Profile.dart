import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:wisebank_frontend/notifications.dart';
import 'personal-infomation.dart';
import 'settings_page.dart';
import 'login_page.dart';


class Profile extends StatelessWidget {
  const Profile({super.key});

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
                  children: const [
                    Text(
                      "Wiseman Bedesho",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "WisemanBedesho@gmail.com",
                      style: TextStyle(
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
              icon: Icons.account_balance_wallet,
              title: "Payment Preferences",
              onTap: () {},
            ),
            buildProfileCard(
              context,
              icon: Icons.add_card_outlined,
              title: "Banks and Cards",
              onTap: () {},
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
              onTap: () {},
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
              onTap: () {
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
      {required IconData icon,
        required String title,
        VoidCallback? onTap}) {
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
