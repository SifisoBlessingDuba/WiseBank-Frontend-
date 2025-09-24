import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionSuccessScreen extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final String recipientName;
  final String fromAccountName;
  final String fromAccountNumber;
  final DateTime transactionTime;

  const TransactionSuccessScreen({
    Key? key,
    required this.amount,
    required this.currencySymbol,
    required this.recipientName,
    required this.fromAccountName,
    required this.fromAccountNumber,
    required this.transactionTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Successful'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Don't show back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Transaction Successful!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              _buildDetailRow('Amount Sent:', '$currencySymbol${amount.toStringAsFixed(2)}'),
              _buildDetailRow('To Recipient:', recipientName),
              _buildDetailRow('From Account:', '$fromAccountName ($fromAccountNumber)'),
              _buildDetailRow('Date & Time:', formatter.format(transactionTime)),
              const SizedBox(height: 40.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Pop all routes until the first one (typically your main dashboard/home screen)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
