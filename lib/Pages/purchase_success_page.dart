import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final String itemType;
  final String provider;
  final String accountUsed;
  final String reference;
  final DateTime purchaseTime;

  const PurchaseSuccessScreen({
    Key? key,
    required this.amount,
    required this.currencySymbol,
    required this.itemType,
    required this.provider,
    required this.accountUsed,
    required this.reference,
    required this.purchaseTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Successful"),
        backgroundColor: Colors.lightBlue[300],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.lightBlue[300], size: 100),
              const SizedBox(height: 20),
              const Text(
                'Purchase Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildDetailRow('Amount Paid:', '$currencySymbol${amount.toStringAsFixed(2)}'),
              _buildDetailRow('Item Type:', itemType),
              _buildDetailRow('Provider:', provider),
              _buildDetailRow('Account Used:', accountUsed),
              _buildDetailRow('Reference:', reference.isEmpty ? 'N/A' : reference),
              _buildDetailRow('Date & Time:', formatter.format(purchaseTime)),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
