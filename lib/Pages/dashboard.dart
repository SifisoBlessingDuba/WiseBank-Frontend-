// dashboard.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wisebank_frontend/services/auth_service.dart';

import 'Profile.dart';
import 'settings_page.dart';
import 'cards.dart';
import 'send_money_screen.dart';
import '../messages/inbox_message_center.dart';
import '../services/api_service.dart'; // Added for ApiService
import '../models/account.dart'; // Added for Account model
import '../services/globals.dart';
import 'pay.dart';
import 'buy_page.dart';
import 'withdrawal_setup_screen.dart';
import 'transaction.dart' as transaction_lib;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final ApiService _apiService = ApiService();
  double? _chequeAccountBalance;
  bool _isLoadingBalance = true;
  String _balanceError = '';

  String userFullName = "";

  @override
  void initState() {
    super.initState();
    print('[Dashboard] initState CALLED');
    _fetchDashboardBalanceData();
    fetchUserName();
  }

  Future<void> _fetchDashboardBalanceData() async {
    print('[Dashboard Balance Fetch] Starting fetch...');
    if (!mounted) return;
    setState(() {
      _isLoadingBalance = true;
      _balanceError = '';
    });

    try {
      // Fetch only this user's accounts instead of all system accounts
      List<Account> accounts = [];
      final token = await authGetToken();
      if (token != null && token.isNotEmpty) {
        // Prefer the authenticated endpoint to avoid email vs id mismatches
        accounts = await _apiService.getMyAccounts();
      } else if (loggedInUserId.isNotEmpty) {
        accounts = await _apiService.getUserAccounts(loggedInUserId);
      }
      // Fallback if nothing returned or userId not set
      if (accounts.isEmpty) {
        print('[Dashboard Balance Fetch] Using fallback getAllAccounts');
        accounts = await _apiService.getAllAccounts();
      }
      if (!mounted) return;
      print('[Dashboard Balance Fetch] Accounts fetched: ${accounts.length}');

      Account? chequeAccount;
      for (var account in accounts) {
        print('[Dashboard Balance Fetch] Checking account: ${account.accountType}, Balance: ${account.accountBalance}');
        final type = account.accountType.toLowerCase();
        if (type == 'cheque' || type == 'current' || type == 'checking') {
          chequeAccount = account;
          break;
        }
      }

      // Fallback: if no cheque/current found, use the first account
      chequeAccount ??= accounts.isNotEmpty ? accounts.first : null;

      if (chequeAccount != null) {
        print('[Dashboard Balance Fetch] Cheque/current account USED: ${chequeAccount.accountBalance}');
        setState(() {
          _chequeAccountBalance = chequeAccount!.accountBalance;
          _isLoadingBalance = false;
        });
      } else {
        print('[Dashboard Balance Fetch] No accounts found for this user.');
        setState(() {
          _chequeAccountBalance = null;
          _isLoadingBalance = false;
          _balanceError = 'No accounts found for this user.';
        });
      }
    } catch (e, s) {
      if (!mounted) return;
      print('[Dashboard Balance Fetch] Error fetching balance: $e');
      print('[Dashboard Balance Fetch] Stacktrace: $s');
      setState(() {
        _isLoadingBalance = false;
        _balanceError = 'Failed to load balance.';
        _chequeAccountBalance = null;
      });
    }
    print('[Dashboard Balance Fetch] Final state: Balance: $_chequeAccountBalance, Loading: $_isLoadingBalance, Error: $_balanceError');
  }

  Future<void> fetchUserName() async {
    if (loggedInUserId.isEmpty) return;
    try {
      final data = await _apiService.getUserDetails(loggedInUserId);
      if (data.isNotEmpty) {
        setState(() {
          userFullName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  // Replaced navigation behavior: use pushReplacement (same as SettingsPage)
  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // already on this tab — do nothing
      return;
    }

    switch (index) {
      case 0:
      // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      case 1:
      // Card
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardsPage()),
        );
        break;
      case 2:
      // Transactions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const transaction_lib.TransactionPage()),
        );
        break;
      case 3:
      // Settings
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Dashboard BUILD CALLED, selectedIndex: $_selectedIndex, isLoadingBalance: $_isLoadingBalance, chequeBalance: $_chequeAccountBalance");

    final List<Widget> pages = [
      HomePage(
        chequeAccountBalance: _chequeAccountBalance,
        isLoadingBalance: _isLoadingBalance,
        balanceError: _balanceError,
      ),
      const CardPage(),
      const transaction_lib.TransactionPage(),
      const Profile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome back, \n${userFullName.isEmpty ? 'User' : userFullName}",
          style: const TextStyle(fontSize: 16),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 28, color: Colors.black),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.black),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxMessageCenterScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ---------------- Home Page ----------------

class HomePage extends StatelessWidget {
  final double? chequeAccountBalance;
  final bool isLoadingBalance;
  final String balanceError;

  const HomePage({
    Key? key,
    this.chequeAccountBalance,
    this.isLoadingBalance = true,
    this.balanceError = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget balanceWidget;
    if (isLoadingBalance) {
      balanceWidget = const CircularProgressIndicator(color: Colors.white);
    } else if (balanceError.isNotEmpty) {
      balanceWidget = Text(balanceError,
          style: const TextStyle(color: Colors.yellow, fontSize: 18));
    } else if (chequeAccountBalance != null) {
      balanceWidget = Text(
        "R ${chequeAccountBalance!.toStringAsFixed(2)}",
        style: const TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      );
    } else {
      balanceWidget = const Text(
        "R N/A",
        style: TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Current Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                balanceWidget,
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickAction(context, Icons.send, "Send", Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SendMoneyScreen()),
                );
              }),
              _quickAction(context, Icons.arrow_downward, "Cardless Withdrawal", Colors.blue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WithdrawalPage()),
                    );
                  }),
              _quickAction(context, Icons.phone_android, "buy", Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuyPage()),
                    );
                  }),
              _quickAction(context, Icons.payment, "Pay", Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PayPage()),
                );
              }),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _transactionTile("Soccer", "-R150.00", "Today, 09:30 AM", false),
          _transactionTile("Bankseta", "+R5,500.00", "25 Aug, 00:00", true),
          _transactionTile("Sifiso Blessing loan", "-R200.00", "23 Aug, 18:45", false),
          _transactionTile("Withdrawal", "-R2000", "21 Aug, 12:32", false),
          _transactionTile("Mali ka Ramaphosa", "+R350.00", "2 Aug, 18:45", true),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withAlpha((0.2 * 255).round()),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _transactionTile(
      String title, String amount, String date, bool isIncome) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(date),
      trailing: Text(amount,
          style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ---------------- Placeholder Pages ----------------

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Card Page - Main Navigation', style: TextStyle(fontSize: 20)),
    );
  }
}

class TransactionPagePlaceholder extends StatelessWidget {
  const TransactionPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Transaction Page', style: TextStyle(fontSize: 20)),
    );
  }
}
