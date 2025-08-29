import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Old Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "New Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Confirm New Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password Changed Successfully")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                }
              },
              child: const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
