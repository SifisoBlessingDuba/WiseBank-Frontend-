import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Privacy Policy for WiseBank

At WiseBank, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information.

1. Information Collection
We collect personal information that you provide to us when you use our services, including your name, contact details, and financial information.

2. Use of Information
Your information is used to provide and improve our services, process transactions, and communicate with you.

3. Data Security
We implement appropriate security measures to protect your data from unauthorized access.

4. Sharing Information
We do not sell your personal information. We may share information with trusted third parties to provide services on our behalf.

5. Your Rights
You have the right to access, correct, or delete your personal information.

6. Changes to this Policy
We may update this Privacy Policy from time to time. We encourage you to review it periodically.

If you have any questions about this Privacy Policy, please contact us.

Thank you for trusting WiseBank.
            ''',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
