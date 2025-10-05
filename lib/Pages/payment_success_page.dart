import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillPaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final String billType;
  final String accountUsed;
  final String reference;
  final DateTime paymentTime;

  const BillPaymentSuccessScreen({
    Key? key,
    required this.amount,
    required this.currencySymbol,
    required this.billType,
    required this.accountUsed,
    required this.reference,
    required this.paymentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.lightBlue[300],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.lightBlue[300],
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Bill Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildDetailRow('Amount Paid:', '$currencySymbol${amount.toStringAsFixed(2)}'),
              _buildDetailRow('Bill Type:', billType),
              _buildDetailRow('Account Used:', accountUsed),
              _buildDetailRow('Reference:', reference.isEmpty ? 'N/A' : reference),
              _buildDetailRow('Date & Time:', formatter.format(paymentTime)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _shareReceipt,
                    child: const Text('Share'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ],
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

  Future<void> _shareReceipt() async {
    try {
      final pdf = pw.Document();
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Bill Payment Receipt',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Bill Type: $billType'),
                pw.Text('Amount Paid: $currencySymbol${amount.toStringAsFixed(2)}'),
                pw.Text('Account Used: $accountUsed'),
                pw.Text('Reference: ${reference.isEmpty ? "N/A" : reference}'),
                pw.Text('Date & Time: ${formatter.format(paymentTime)}'),
              ],
            ),
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'bill_receipt.pdf',
      );
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
    }
  }
}
