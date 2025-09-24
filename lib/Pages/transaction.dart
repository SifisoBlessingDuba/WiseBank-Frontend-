import 'package:flutter/material.dart';

// Transaction model
class Transaction {
  final String title;
  final String amount;
  final String date;
  final bool isIncome;

  const Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  // Predefined 20 transactions (chronological order: oldest first)
  final List<Transaction> transactions = const [
    Transaction(title: "July Rent", amount: "-R5,000.00", date: "1 Jul, 09:00", isIncome: false),
    Transaction(title: "July Salary", amount: "+R8,000.00", date: "15 Jul, 12:00", isIncome: true),
    Transaction(title: "Grocery", amount: "-R450.00", date: "17 Jul, 18:45", isIncome: false),
    Transaction(title: "Gym Membership", amount: "-R300.00", date: "20 Jul, 07:30", isIncome: false),
    Transaction(title: "Electricity Bill", amount: "-R1,200.00", date: "25 Jul, 14:00", isIncome: false),
    Transaction(title: "July Bonus", amount: "+R1,500.00", date: "30 Jul, 16:00", isIncome: true),
    Transaction(title: "August Salary", amount: "+R8,500.00", date: "1 Aug, 12:00", isIncome: true),
    Transaction(title: "Withdrawal", amount: "-R2,000.00", date: "2 Aug, 09:30", isIncome: false),
    Transaction(title: "Mali ka Ramaphosa", amount: "+R350.00", date: "2 Aug, 18:45", isIncome: true),
    Transaction(title: "Soccer", amount: "-R150.00", date: "3 Aug, 09:30", isIncome: false),
    Transaction(title: "Bankseta", amount: "+R5,500.00", date: "5 Aug, 00:00", isIncome: true),
    Transaction(title: "Sifiso Blessing Loan", amount: "-R200.00", date: "7 Aug, 18:45", isIncome: false),
    Transaction(title: "Water Bill", amount: "-R350.00", date: "8 Aug, 10:15", isIncome: false),
    Transaction(title: "Netflix", amount: "-R120.00", date: "9 Aug, 20:00", isIncome: false),
    Transaction(title: "Spotify", amount: "-R99.00", date: "10 Aug, 08:00", isIncome: false),
    Transaction(title: "Deposit", amount: "+R1,000.00", date: "12 Aug, 11:00", isIncome: true),
    Transaction(title: "Withdrawal", amount: "-R500.00", date: "14 Aug, 14:30", isIncome: false),
    Transaction(title: "Uber Ride", amount: "-R250.00", date: "16 Aug, 19:00", isIncome: false),
    Transaction(title: "Salary Payment", amount: "+R8,500.00", date: "18 Aug, 12:00", isIncome: true),
    Transaction(title: "Amazon Purchase", amount: "-R1,200.00", date: "20 Aug, 15:45", isIncome: false),
  ];

  @override
  Widget build(BuildContext context) {
    // Reverse the list so August is at the top
    final reversedTransactions = transactions.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true, // shows the scrollbar thumb
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reversedTransactions.length,
          itemBuilder: (context, index) {
            final tx = reversedTransactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: tx.isIncome ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    tx.date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: Text(
                    tx.amount,
                    style: TextStyle(
                      color: tx.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  }
