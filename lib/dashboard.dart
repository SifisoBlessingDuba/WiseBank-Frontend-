import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Profile.dart';
import 'settings_page.dart';
import 'cards.dart';
import 'send_money_screen.dart';
import 'messages/inbox_message_center.dart';
import 'services/api_service.dart'; // Added for ApiService
import 'models/account.dart'; // Added for Account model
import 'transaction.dart';
import 'globals.dart';



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
  String _balanceError = ''; // To store any error messages

  String userFullName = ""; // Will store fetched name


  @override
  void initState() {
    print('[Dashboard Balance Fetch] _DashboardState initState CALLED');
    super.initState();
    _fetchDashboardBalanceData();
  }

  Future<void> _fetchDashboardBalanceData() async {
    print('[Dashboard Balance Fetch] Starting fetch...');
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _isLoadingBalance = true;
      _balanceError = ''; // Reset error on new fetch
    });

    try {
      final List<Account> accounts = await _apiService.getAllAccounts();
      if (!mounted) return;
      print('[Dashboard Balance Fetch] Accounts fetched successfully: ${accounts
          .length} accounts');

      Account? chequeAccount;
      for (var account in accounts) {
        print('[Dashboard Balance Fetch] Checking account: Name: ${account
            .accountType}, Balance: ${account.accountBalance}');
        if (account.accountType == "Cheque") {
          chequeAccount = account;
          break;
        }
      }

      if (chequeAccount != null) {
        print(
            '[Dashboard Balance Fetch] Cheque account FOUND: Balance: ${chequeAccount
                .accountBalance}');
        setState(() {
          _chequeAccountBalance = chequeAccount!.accountBalance;
          _isLoadingBalance = false;
        });
      } else {
        print('[Dashboard Balance Fetch] Cheque account NOT found.');
        setState(() {
          _chequeAccountBalance = null; // Ensure balance is null if not found
          _isLoadingBalance = false;
          _balanceError = 'Cheque account not found.';
        });
      }
    } catch (e, s) {
      if (!mounted) return;
      print('[Dashboard Balance Fetch] Error fetching balance: $e');
      print('[Dashboard Balance Fetch] Stacktrace: $s');
      setState(() {
        _isLoadingBalance = false;
        _balanceError = 'Failed to load balance.';
        _chequeAccountBalance = null; // Ensure balance is null on error
      });
    }
    print(
        '[Dashboard Balance Fetch] Final state before UI update: Balance: $_chequeAccountBalance, Loading: $_isLoadingBalance, Error: $_balanceError');
  }

  @override
  void initState() {
    super.initState();
    fetchUserName(); // fetch name when dashboard loads
  }

  Future<void> fetchUserName() async {
    if (loggedInUserId.isEmpty) return;
    String user = loggedInUserId;

    final url =
    Uri.parse('http://10.0.2.2:8080/user/read_user/$user');

    try {
      final response = await http.get(url);

      print("API response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userFullName = "${data['firstName']} ${data['lastName']}";
        });
      } else {
        print("Error fetching user: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  void _onItemTapped(int index) {
    
    if (index == 3) { // Settings icon

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );

    } else if (index == 1) { // Card icon in bottom nav

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CardsPage()),
      );

    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TransactionPage()),
      );

    } else {
      if (!mounted) return;
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Dashboard BUILD CALLED, selectedIndex: $_selectedIndex, isLoadingBalance: $_isLoadingBalance, chequeBalance: $_chequeAccountBalance");

    // Define pages here so HomePage gets updated state
    final List<Widget> pages = [
      HomePage(
        chequeAccountBalance: _chequeAccountBalance,
        isLoadingBalance: _isLoadingBalance,
        balanceError: _balanceError,
      ),
      const CardPage(),
      const TransactionPage(),
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
                MaterialPageRoute(
                    builder: (context) => const InboxMessageCenterScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex > 1 ? 0 : _selectedIndex,
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



// Pages
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Dashboard Page', style: TextStyle(fontSize: 20)),
//     );
//   }
// }


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
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold),
      );
    } else {
      balanceWidget = const Text(
        "R N/A", // Default if no error but balance is null
        style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold),
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
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Current Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 10),
                balanceWidget, // Dynamically display balance or loading/error
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
              _quickAction(
                  context, Icons.arrow_downward, "Deposit", Colors.blue, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deposit Tapped")),
                );
              }),
              _quickAction(
                  context, Icons.phone_android, "Airtime", Colors.orange, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Airtime Tapped")),
                );
              }),
              _quickAction(context, Icons.payment, "Pay", Colors.purple, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pay Tapped")),
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
          _transactionTile(
              "Sifiso Blessing loan", "-R200.00", "23 Aug, 18:45", false),
          _transactionTile("Withdrawal", "-R2000", "21 Aug, 12:32", false),
          _transactionTile(
              "Mali ka Ramaphosa", "+R350.00", "2 Aug, 18:45", true),
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
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _transactionTile(String title, String amount, String date,
      bool isIncome) {
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

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          'Card Page - Main Navigation', style: TextStyle(fontSize: 20)),
    );
  }
}

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Transaction Page', style: TextStyle(fontSize: 20)),
    );
  }
}