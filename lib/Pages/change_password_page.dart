import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/globals.dart'; // For loggedInUserId

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    oldPasswordController.addListener(_validateForm);
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled = oldPasswordController.text.isNotEmpty &&
          newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          newPasswordController.text.length >= 6 &&
          newPasswordController.text == confirmPasswordController.text;
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Fetch current user data
      final userResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/user/read_user/$loggedInUserId'),
      );

      if (userResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user data")),
        );
        return;
      }

      Map<String, dynamic> userJson = jsonDecode(userResponse.body);

      // Check old password
      if (userJson['password'] != oldPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Old password is incorrect")),
        );
        return;
      }

      // Update password field
      userJson['password'] = newPasswordController.text;

      // Send PUT request to update user
      final updateResponse = await http.put(
        Uri.parse('http://10.0.2.2:8080/user/update'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userJson),
      );

      if (updateResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully")),
        );
        Navigator.pop(context);
      } else {
        print('Failed PUT response: ${updateResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Old Password",
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter old password" : null,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter new password";
                      if (value.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password",
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Confirm new password";
                      if (value != newPasswordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _changePassword : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Change Password"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
