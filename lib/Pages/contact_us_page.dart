import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get in Touch with WiseBank',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildContactCard(
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '+27 21 123 4567',
                description: 'Available 24/7 for urgent banking matters',
              ),
              
              const SizedBox(height: 16),
              
              _buildContactCard(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@wisebank.co.za',
                description: 'For general inquiries and support',
              ),
              
              const SizedBox(height: 16),
              
              _buildContactCard(
                icon: Icons.location_on,
                title: 'Head Office',
                subtitle: '123 Financial District, Cape Town, 8001',
                description: 'Visit us during business hours',
              ),
              
              const SizedBox(height: 16),
              
              _buildContactCard(
                icon: Icons.access_time,
                title: 'Business Hours',
                subtitle: 'Monday - Friday: 8:00 AM - 5:00 PM',
                description: 'Saturday: 9:00 AM - 1:00 PM',
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Emergency Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'For lost or stolen cards, please call immediately:\n+27 21 999 9999',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
