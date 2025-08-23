import 'package:flutter/material.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  bool isEditing = false;

  final TextEditingController _nameController =
  TextEditingController(text: "Wiseman");
  final TextEditingController _surnameController =
  TextEditingController(text: "Bedesho");
  final TextEditingController _emailController =
  TextEditingController(text: "WisemanBedesho@gmail.com");
  final TextEditingController _passwordController =
  TextEditingController(text: "123456");
  final TextEditingController _confirmPasswordController =
  TextEditingController(text: "123456");
  final TextEditingController _dobController =
  TextEditingController(text: "01/01/2000");
  final TextEditingController _addressController =
  TextEditingController(text: "143 Sir Lowry Road, Woodstock, Cape Town");
  final TextEditingController _cellphoneController =
  TextEditingController(text: "0712345678");


  String? _countryOfBirth = "South Africa";
  String? _countryOfResidence = "South Africa";

  final List<String> _countries = [
    "South Africa",
    "Zimbabwe",
    "Nigeria",
    "Kenya",
    "USA",
    "UK",
  ];

  Future<void> _selectDate(BuildContext context) async {
    if (!isEditing) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
        "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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

  Widget buildDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: _countries
            .map((country) => DropdownMenuItem(
          value: country,
          child: Text(country),
        ))
            .toList(),
        onChanged: isEditing ? onChanged : null,
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
      body: Padding(
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
            buildField(
                label: "Password",
                controller: _passwordController,
                icon: Icons.lock,
                obscure: true,
                readOnly: !isEditing),
            buildField(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                obscure: true,
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
            buildDropdown(
                label: "Country of Birth",
                value: _countryOfBirth,
                onChanged: (val) => setState(() => _countryOfBirth = val),
                icon: Icons.flag),
            buildDropdown(
                label: "Country of Residence",
                value: _countryOfResidence,
                onChanged: (val) => setState(() => _countryOfResidence = val),
                icon: Icons.home),
            buildField(
                label: "Cellphone Number",
                controller: _cellphoneController,
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
                if (isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Information updated successfully")),
                  );
                }
                setState(() {
                  isEditing = !isEditing;
                });
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
