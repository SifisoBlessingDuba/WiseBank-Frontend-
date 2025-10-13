import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Transaction model
class Transaction {
  final String title;
  final double amount;
  final String date;
  final bool isIncome;

  const Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      title: json['description'] ?? 'No Description',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['timestamp'] ?? '',
      isIncome: (json['transactionType'] ?? '').toString().toLowerCase() == 'deposit' ||
          (json['transactionType'] ?? '').toString().toLowerCase() == 'credit',
    );
  }
}

//Fetching transactions from the database using the API //

Future<List<Transaction>> fetchTransactions() async {
  final response = await http.get(Uri.parse('http://localhost:8081/transaction/find-all'));

  if (response.statusCode == 200) {
    final List<dynamic> txList = json.decode(response.body);
    return txList.map((json) => Transaction.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load transactions');
  }
}

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});


  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Transaction>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final transactions = snapshot.data!.reversed.toList(); // latest first
          return Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
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
                        (tx.isIncome ? "+" : "-") + "R${tx.amount.toStringAsFixed(2)}",
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
          );
        },
      ),
    );
  }
}