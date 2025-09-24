import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = _dateFormatter.format(picked);
      });
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match!");
      return;
    }

    if (_idController.text.isEmpty) {
      _showErrorDialog("ID Number is required!");
      return;
    }

    final now = DateTime.now();
    final String createdAt = _dateFormatter.format(now);
    final String lastLogin = _dateFormatter.format(now);

    final Map<String, dynamic> userData = {
      "idNumber": _idController.text.trim(),
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "dateOfBirth": _dobController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
      "createdAt": createdAt,
      "lastLogin": lastLogin,
    };

    // Debug print
    print("🔹 Sending user data: ${jsonEncode(userData)}");

    final url = Uri.parse('http://10.0.2.2:8080/user/save');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        print("✅ Signup success! Response: ${response.body}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print("❌ Signup failed. Code: ${response.statusCode}, Body: ${response.body}");
        _showErrorDialog(
            "Failed to sign up. Code: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      print("⚠️ Error during signup: $e");
      _showErrorDialog("Error: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign Up Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, bool obscure,
      {VoidCallback? onTap, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: onTap != null
              ? IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: onTap,
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField(_idController, "ID Number", false),
            _buildInputField(_firstNameController, "First Name", false),
            _buildInputField(_lastNameController, "Last Name", false),
            _buildInputField(_emailController, "Email", false),
            _buildInputField(_passwordController, "Password", true),
            _buildInputField(_confirmPasswordController, "Confirm Password", true),
            _buildInputField(
              _dobController,
              "Date of Birth",
              false,
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            _buildInputField(_addressController, "Address", false),
            _buildInputField(_phoneController, "Phone Number", false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
