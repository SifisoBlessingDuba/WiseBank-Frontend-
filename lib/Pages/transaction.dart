import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';
//import 'globals.dart';

// Transaction model
class Transaction {
  final String title;
  final double amount;
  final String date;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    double parsedAmount;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else {
      parsedAmount = double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;
    }

    final txType = (json['transactionType'] ?? '').toString().toLowerCase();

    return Transaction(
      title: json['description'] ?? 'No Description',
      amount: parsedAmount,
      date: json['timestamp']?.toString() ?? '',
      isIncome: txType == 'deposit' || txType == 'credit',
    );
  }
}

Future<List<Transaction>> fetchTransactions() async {
  final uri = Uri.parse('$apiBaseUrl/transaction/find-all');

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> txList = jsonDecode(response.body);
    return txList.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load transactions: ${response.statusCode}');
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

          final transactions = snapshot.data!.reversed.toList();
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
                        "${tx.isIncome ? '+' : '-'}R${tx.amount.toStringAsFixed(2)}",
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
