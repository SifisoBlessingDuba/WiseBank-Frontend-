import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

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
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    final url = Uri.parse("http://10.0.2.2:8080/user/change_password");
    final body = jsonEncode({
      "email": loggedInUserId,
      "oldPassword": oldPasswordController.text.trim(),
      "newPassword": newPasswordController.text.trim(),
    });

    print("🔹 Sending change password request: $body");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("🔹 Response: ${response.statusCode}, Body: ${response.body}");

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password changed successfully")),
          );
          Navigator.pop(context);
        } else {
          _showErrorDialog(data["message"] ?? "Failed to change password");
        }
      } else if (response.statusCode == 401) {
        _showErrorDialog("Old password is incorrect.");
      } else if (response.statusCode == 404) {
        _showErrorDialog("User not found.");
      } else {
        _showErrorDialog("Failed. Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Network error: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
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
                      if (value == null || value.isEmpty) {
                        return "Enter new password";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
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
                      if (value == null || value.isEmpty) {
                        return "Confirm new password";
                      } else if (value != newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled && !_isLoading ? _changePassword : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Change Password"),
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
