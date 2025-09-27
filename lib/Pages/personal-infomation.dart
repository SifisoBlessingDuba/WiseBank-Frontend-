import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/globals.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/read_user/$loggedInUserId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userJson = jsonDecode(response.body);

        _nameController.text = userJson['firstName'] ?? '';
        _surnameController.text = userJson['lastName'] ?? '';
        _emailController.text = userJson['email'] ?? '';
        _dobController.text = userJson['dateOfBirth'] ?? '';
        _addressController.text = userJson['address'] ?? '';
        _phoneController.text = userJson['phoneNumber'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    try {
      final userJson = {
        "idNumber": loggedInUserId,
        "firstName": _nameController.text,
        "lastName": _surnameController.text,
        "email": _emailController.text,
        "dateOfBirth": _dobController.text,
        "phoneNumber": _phoneController.text,
        "address": _addressController.text,
      };

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/user/update'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userJson),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Information updated successfully")),
        );
        setState(() => isEditing = false);
      } else {
        print('PUT response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update information")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating user: $e")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!isEditing) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Account Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildField(
                label: "Name",
                controller: _nameController,
                icon: Icons.person,
                readOnly: !isEditing),
            buildField(
                label: "Surname",
                controller: _surnameController,
                icon: Icons.badge,
                readOnly: !isEditing),
            buildField(
                label: "Email Address",
                controller: _emailController,
                icon: Icons.email,
                readOnly: !isEditing),

            const SizedBox(height: 20),
            const Text(
              "Personal Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildField(
              label: "Date of Birth",
              controller: _dobController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            buildField(
                label: "Cellphone Number",
                controller: _phoneController,
                icon: Icons.phone,
                readOnly: !isEditing),
            buildField(
                label: "Address",
                controller: _addressController,
                icon: Icons.location_on_outlined,
                readOnly: !isEditing),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (isEditing) _updateUserData();
                setState(() => isEditing = !isEditing);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? "Save" : "Update",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
