import 'package:flutter/material.dart';

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

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      if (newPasswordController.text == confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password Changed Successfully")),
        );
        Navigator.pop(context);
      }
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
