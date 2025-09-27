import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dashboard.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Loading indicator
  bool _isLoading = false;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

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
        dobController.text = _dateFormatter.format(picked);
      });
    }
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if ((_formKeys[0].currentState?.validate() ?? false) &&
        (_formKeys[1].currentState?.validate() ?? false)) {
      setState(() => _isLoading = true);

      // Format createdAt and lastLogin as yyyy-MM-dd (matches LocalDate)
      String createdAt = _dateFormatter.format(DateTime.now());
      String lastLogin = _dateFormatter.format(DateTime.now());

      Map<String, dynamic> userData = {
        "idNumber": idNumberController.text, // backend expects String
        "email": emailController.text,
        "password": passwordController.text,
        "firstName": firstNameController.text,
        "lastName": surnameController.text,
        "dateOfBirth": dobController.text, // already yyyy-MM-dd
        "phoneNumber": phoneController.text,
        "address": addressController.text,
        "createdAt": createdAt,
        "lastLogin": lastLogin,
      };

      print("🔹 Sending User Data: $userData");

      try {
        final response = await http.post(
          Uri.parse("http://localhost:8080/user/save"),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
          },
          body: jsonEncode(userData),
        );

        setState(() => _isLoading = false);

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("✅ User registered successfully: ${response.body}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Account created successfully!"),
                  backgroundColor: Colors.green),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          }
        } else {
          print("❌ Failed to register user: ${response.statusCode}");
          print("Response body: ${response.body}");
          String errorMessage = "Error: please correct errors in this form";
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(errorMessage), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        print("⚠️ Error during signup: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text("Network error or server issue. Please try again."),
                backgroundColor: Colors.red),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error: please correct errors in this form"),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  Widget _buildAccountInfoStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your email";
                }
                if (!value.contains("@")) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter a password";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value != passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: idNumberController,
              decoration: const InputDecoration(
                labelText: "ID Number",
                prefixIcon: Icon(Icons.badge, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your ID number";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name",
                prefixIcon: Icon(Icons.person, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your first name";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: surnameController,
              decoration: const InputDecoration(
                labelText: "Surname",
                prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your surname";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.blue),
                  onPressed: () => _selectDate(context),
                ),
              ),
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Select your date of birth";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your address";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter your phone number";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0
            ? "Account Information"
            : "Personal Information"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 2,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAccountInfoStep(),
                  _buildPersonalInfoStep(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: _previousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Back"),
                  )
                else
                  const SizedBox(width: 100),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(_currentStep == 0 ? "Continue" : "Sign Up"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    idNumberController.dispose();
    firstNameController.dispose();
    surnameController.dispose();
    dobController.dispose();
    addressController.dispose();
    phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
