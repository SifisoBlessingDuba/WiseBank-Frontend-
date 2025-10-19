import 'package:flutter/material.dart';
import 'dashboard.dart';
import '../services/globals.dart';
import 'forgot-information.dart';
import 'package:wisebank_frontend/services/auth_service.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await authLogin(
        username: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (token != null) {
        // store logged in user id for legacy places in app
        loggedInUserId = emailController.text.trim();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        _showErrorDialog("Invalid ID number or password.");
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
        title: const Text("Login Error"),
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset("assets/logo.png", height: 120),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "ID Number:",
                          prefixIcon: Icon(Icons.email, color: Colors.blue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? "Enter ID number" : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter password"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled ? _login : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Login"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotInformationPage()),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}