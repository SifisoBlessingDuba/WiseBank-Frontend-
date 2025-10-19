import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


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
        title: const Text('Purchase Successful'),
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
                'Purchase Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildDetailRow('Amount:', '$currencySymbol${amount.toStringAsFixed(2)}'),
              _buildDetailRow('Item Type:', itemType),
              _buildDetailRow('Provider:', provider),
              _buildDetailRow('Account Used:', accountUsed),
              _buildDetailRow('Reference:', reference.isEmpty ? 'N/A' : reference),
              _buildDetailRow('Date & Time:', formatter.format(purchaseTime)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () => _shareReceipt(context),
                    child: const Text('Share'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('Purchase Receipt',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text('Item Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Item Type: $itemType'),
                pw.Text('Provider: $provider'),
                pw.Text('Amount: $currencySymbol${amount.toStringAsFixed(2)}'),
                pw.SizedBox(height: 12),
                pw.Text('Account & Reference', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Account Used: $accountUsed'),
                pw.Text('Reference: ${reference.isEmpty ? "N/A" : reference}'),
                pw.SizedBox(height: 12),
                pw.Text('Date & Time', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(formatter.format(purchaseTime)),
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text('Thank you for using WiseBank', style: pw.TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      await Printing.sharePdf(bytes: bytes, filename: 'purchase_receipt.pdf');
    } catch (e) {
      // keep debug info quiet in production; show a snackbar in-app for user feedback
      debugPrint('Error exporting receipt PDF: $e');
      ScaffoldMessenger.of(navigatorKeyOrContext(context)).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  // Helper to safely obtain a BuildContext's ScaffoldMessenger root if the direct one isn't available.
  BuildContext navigatorKeyOrContext(BuildContext ctx) {
    // prefer provided context
    return ctx;
  }
}
