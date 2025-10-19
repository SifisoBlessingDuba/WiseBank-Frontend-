// transaction_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';

// Pages for navigation
import 'dashboard.dart';
import 'cards.dart';
import 'Profile.dart';
import 'settings_page.dart';

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
    final description = json['description'] ?? json['title'] ?? 'No Description';

    double amountValue = 0.0;
    final rawAmount = json['amount'];
    if (rawAmount is num) {
      amountValue = rawAmount.toDouble();
    } else if (rawAmount is String) {
      amountValue = double.tryParse(rawAmount) ?? 0.0;
    }

    String dateString = '';
    final ts = json['timestamp'] ?? json['date'] ?? '';
    if (ts is int) {
      try {
        dateString = DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toString();
      } catch (_) {
        dateString = ts.toString();
      }
    } else if (ts is String && ts.isNotEmpty) {
      try {
        dateString = DateTime.parse(ts).toLocal().toString();
      } catch (_) {
        dateString = ts;
      }
    }

    final txType = (json['transactionType'] ?? '').toString().toLowerCase();
    final isIncome = txType == 'deposit' || txType == 'credit' || txType == 'in';

    return Transaction(
      title: description,
      amount: amountValue,
      date: dateString,
      isIncome: isIncome,
    );
  }
}

// Fetch transactions
Future<List<Transaction>> fetchTransactions() async {
  final uri = Uri.parse('$apiBaseUrl/transaction/find-all');
  try {
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> listData = [];

      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        listData = decoded['data'];
      } else if (decoded is Map && decoded.containsKey('transactions') && decoded['transactions'] is List) {
        listData = decoded['transactions'];
      } else if (decoded is Map) {
        listData = [decoded];
      } else {
        throw Exception('Unexpected JSON structure');
      }

      return listData.map((json) => Transaction.fromJson(Map<String, dynamic>.from(json))).toList();
    } else {
      throw Exception('Failed to load transactions (status: ${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Error fetching transactions: $e');
  }
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int _selectedIndex = 2; // Transactions tab

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Already on this tab

    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
        break;
      case 1: // Cards
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CardsPage()));
        break;
      case 2: // Transactions
        break; // Already here
      case 3: // Settings
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
        automaticallyImplyLeading: false, // no back arrow
        backgroundColor: Colors.white,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Card'),
          BottomNavigationBarItem(icon: Icon(Icons.money_outlined), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
