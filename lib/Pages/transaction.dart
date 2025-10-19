import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart'; // make sure apiBaseUrl is defined here

// Transaction model
class Transaction {
  final String title;
  final double amount;
  final String date; // human-friendly date string
  final bool isIncome;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Some APIs use different keys; adapt if needed
    final description = json['description'] ?? json['title'] ?? 'No Description';

    double amountValue = 0.0;
    final rawAmount = json['amount'];
    if (rawAmount is num) {
      amountValue = rawAmount.toDouble();
    } else if (rawAmount is String) {
      amountValue = double.tryParse(rawAmount) ?? 0.0;
    }

    // timestamp may be an ISO string or epoch millis; try to normalize
    String dateString = '';
    final ts = json['timestamp'] ?? json['date'] ?? '';
    if (ts is int) {
      // epoch milliseconds
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts);
        dateString = dt.toLocal().toString();
      } catch (_) {
        dateString = ts.toString();
      }
    } else if (ts is String && ts.isNotEmpty) {
      // try to parse ISO string
      try {
        final dt = DateTime.parse(ts);
        dateString = dt.toLocal().toString();
      } catch (_) {
        // fallback to raw string
        dateString = ts;
      }
    }

    final txType = (json['transactionType'] ?? '').toString().toLowerCase();
    final isIncome = txType == 'deposit' || txType == 'credit' || txType == 'in';

    return Transaction(
      title: description.toString(),
      amount: amountValue,
      date: dateString,
      isIncome: isIncome,
    );
  }
}

// Fetch transactions from the API
Future<List<Transaction>> fetchTransactions() async {
  final uri = Uri.parse('$apiBaseUrl/transaction/find-all');
  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Debugging: helpful if you get unexpected data
    debugPrint('fetchTransactions: status=${response.statusCode}');
    debugPrint('fetchTransactions: body=${response.body}');

    if (response.statusCode == 200) {
      final body = response.body.trim();
      final decoded = jsonDecode(body);

      List<dynamic> listData = [];

      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        listData = decoded['data'];
      } else if (decoded is Map && decoded.containsKey('transactions') && decoded['transactions'] is List) {
        listData = decoded['transactions'];
      } else {
        // If API returned an object with a single transaction, convert to list
        if (decoded is Map) {
          listData = [decoded];
        } else {
          throw Exception('Unexpected JSON structure');
        }
      }

      return listData.map((json) {
        if (json is Map<String, dynamic>) {
          return Transaction.fromJson(json);
        } else if (json is Map) {
          return Transaction.fromJson(Map<String, dynamic>.from(json));
        } else {
          throw Exception('Invalid transaction entry');
        }
      }).toList();
    } else {
      throw Exception('Failed to load transactions (status: ${response.statusCode})');
    }
  } catch (e) {
    // Re-throw so FutureBuilder shows the error
    throw Exception('Error fetching transactions: $e');
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
