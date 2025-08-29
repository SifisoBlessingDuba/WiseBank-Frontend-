import 'package:flutter/material.dart';
import 'Profile.dart';
import 'settings_page.dart';
import 'cards.dart';
import 'send_money_screen.dart'; // Added import for SendMoneyScreen
import 'messages/inbox_message_center.dart'; // Added import for InboxMessageCenterScreen

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CardPage(), // Assuming this is a different CardPage, not CardsPage from cards.dart
    const TransactionPage(),
    const Profile(),


  ];

  void _onItemTapped(int index) {
    if (index == 3) { // Settings icon
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    } else if (index == 1) { // Card icon in bottom nav
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CardsPage()), // Navigates to CardsPage from cards.dart
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome back, \nItumeleng Wiseman",
          style: TextStyle(fontSize: 16),
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
        actions: [ // Added actions for the message icon
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.black), // Added message icon
            tooltip: 'Messages',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxMessageCenterScreen()),
              );
            },
          ),
          const SizedBox(width: 10), // Optional: for a bit of spacing
        ],
      ),
      body: _pages[_selectedIndex],
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Text("Current Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 10),
                Text("R7,600.55",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
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
                  MaterialPageRoute(builder: (context) => const SendMoneyScreen()),
                );
              }),
              _quickAction(context, Icons.arrow_downward, "Deposit", Colors.blue, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deposit Tapped")),
                );
              }),
              _quickAction(context, Icons.phone_android, "Airtime", Colors.orange, () {
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
          _transactionTile("Sifiso Blessing loan", "-R200.00", "23 Aug, 18:45", false),
          _transactionTile("Withdrawal", "-R2000", "21 Aug, 12:32", false),
          _transactionTile("Mali ka Ramaphosa", "+R350.00", "2 Aug, 18:45", true),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
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

class CardPage extends StatelessWidget {
  const CardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Card Page - Main Navigation', style: TextStyle(fontSize: 20)),
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
