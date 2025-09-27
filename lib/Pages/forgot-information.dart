import 'package:flutter/material.dart';

class ForgotInformationPage extends StatelessWidget {
  const ForgotInformationPage({super.key});

  final List<Map<String, String>> branches = const [
    {
      "name": "Cape Town Branch",
      "address": "123 Main Road, Cape Town",
      "phone": "021 123 4567"
    },
    {
      "name": "Johannesburg Branch",
      "address": "456 Market Street, Johannesburg",
      "phone": "011 234 5678"
    },
    {
      "name": "Durban Branch",
      "address": "789 Ocean Drive, Durban",
      "phone": "031 345 6789"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Information"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Forgot Your Account Details or Password?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "For security reasons, WiseBank does not allow you to reset your password or retrieve account details online without first logging in. "
                  "Please contact one of our branches or customer support for assistance.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Customer Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text("Call Us"),
                subtitle: const Text("0800 123 456"),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text("Email Support"),
                subtitle: const Text("support@wisebank.co.za"),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Branches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...branches.map(
                  (branch) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(branch["name"]!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch["address"]!),
                      const SizedBox(height: 4),
                      Text("Phone: ${branch["phone"]}"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Optionally, open email or phone dialer
                },
                icon: const Icon(Icons.contact_support),
                label: const Text("Contact Support"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
