import 'package:flutter/material.dart';

// ---------------- Mock Transaction Data ----------------
final List<Map<String, dynamic>> mockTransactions = [
  {
    'title': 'Bankseta Payment',
    'amount': 5500.0,
    'date': '25 Oct 2025, 10:30 AM',
    'isIncome': true
  },
  {
    'title': 'Soccer',
    'amount': 200.0,
    'date': 'Today, 09:30 PM',
    'isIncome': false
  },
  {
    'title': 'Sifiso Blessing loan',
    'amount': 200.0,
    'date': '17 Oct 2025, 06:45 PM',
    'isIncome': false
  },
  {
    'title': 'Mali ka Ramaphosa',
    'amount': 1500.0,
    'date': '02 Aug 2025, 18:45 AM',
    'isIncome': true
  },
];

// ---------------- Transaction Page ----------------
class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // same theme as dashboard
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockTransactions.length,
        itemBuilder: (context, index) {
          final tx = mockTransactions[index];
          final bool isIncome = tx['isIncome'] as bool;
          final String title = tx['title'] as String;
          final String date = tx['date'] as String;
          final double amount = tx['amount'] as double;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  date,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                trailing: Text(
                  "${isIncome ? '+' : '-'}R${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  // Navigate to detailed transaction page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(transaction: tx),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Transaction Detail Page ----------------
class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction['isIncome'] as bool;
    final String title = transaction['title'] as String;
    final String date = transaction['date'] as String;
    final double amount = transaction['amount'] as double;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Date: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(date, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Amount: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${isIncome ? '+' : '-'}R${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Type: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  isIncome ? 'Income' : 'Expense',
                  style: TextStyle(
                    fontSize: 16,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Placeholder for more details like description, transaction ID, etc.
            const Text(
              'Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              // 'This is a placeholder description for the transaction. When backend is ready, this will show full details.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


