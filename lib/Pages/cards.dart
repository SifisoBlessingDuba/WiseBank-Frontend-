// cards_page.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:wisebank_frontend/services/auth_service.dart';
import 'package:wisebank_frontend/services/endpoints.dart';
import 'package:wisebank_frontend/services/api_service.dart';

import 'dashboard.dart';
import 'transaction.dart' as transaction_lib;
import 'settings_page.dart';
import '../services/globals.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class CardModel {
  String cardHolder;
  String cardNumber;
  String expiryDate;
  String cvv;
  String issueDate;
  String cardType;
  double cardLimit;
  String status;

  CardModel({
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.issueDate,
    required this.cardType,
    required this.cardLimit,
    required this.status,
  });

  // Factory to create from backend JSON
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardHolder: json['user']?['name'] ?? "Unknown",
      cardNumber: json['cardNumber'] ?? "",
      expiryDate: json['expiryDate'] ?? "",
      cvv: json['cvv'].toString(),
      issueDate: json['issuedDate'] ?? "",
      cardType: json['cardType'] ?? "",
      cardLimit: (json['cardLimit'] ?? 0).toDouble(),
      status: (json['status'] == true || json['status'] == "Active")
          ? "Active"
          : "Blocked",
    );
  }
}

class _CardsPageState extends State<CardsPage> {
  List<CardModel> cards = [];

  // Bank Info (can also be per card if needed)
  String bankName = "WiseBank";
  String accountNumber = "1234567890";
  String branchCode = "012345";

  @override
  void initState() {
    super.initState();
    fetchUserName().then((_) {
      fetchCards();
    });
  }


  Future<void> fetchCards() async {
    try {
      final dio = AuthService.instance.dio;
      final res = await dio.get('${Endpoints.baseUrl}/card/all_cards');
      final dynamic data = res.data is String ? jsonDecode(res.data) : res.data;
      if (data is List) {
        setState(() {
          cards = data.map((json) {
            final m = Map<String, dynamic>.from(json);
            final card = CardModel.fromJson(m);
            card.cardHolder = cardHolderName.isNotEmpty ? cardHolderName : loggedInUserId;
            return card;
          }).toList();
        });
      } else {
        debugPrint('Failed to load cards: unexpected response shape');
      }
    } catch (e) {
      debugPrint("Error fetching cards: $e");
    }
  }

  String cardHolderName = "";

  Future<void> fetchUserName() async {
    if (loggedInUserId.isEmpty) return;

    try {
      final dio = AuthService.instance.dio;
      final res = await dio.get(Endpoints.userById(loggedInUserId));
      final dynamic data = res.data is String ? jsonDecode(res.data) : res.data;
      if (data is Map<String, dynamic>) {
        setState(() {
          cardHolderName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        });
      }
    } catch (e) {
      debugPrint('fetchUserName (dio) error: $e');
    }
  }

  Future<void> updateCard(Map<String, dynamic> card) async {
    try {
      final dio = AuthService.instance.dio;
      final res = await dio.put('${Endpoints.baseUrl}/card/update', data: card);
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('Card updated successfully');
        fetchCards();
      } else {
        print('Failed to update card: ${res.statusCode}');
      }
    } catch (e) {
      print('Error updating card: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Column(
                  children: [
                    // Card UI
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      color: Colors.blueAccent,
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bankName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              card.cardNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCardInfoColumn(
                                    "Card Holder", card.cardHolder),
                                _buildCardInfoColumn(
                                    "Expiry", card.expiryDate),
                                _buildCardInfoColumn("CVV", card.cvv),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCardInfoColumn(
                                    "Issue Date", card.issueDate),
                                _buildCardInfoColumn(
                                    "Card Type", card.cardType),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Editable Card Limit
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        title: const Text("Card Limit"),
                        subtitle: Text("R ${card.cardLimit}"),
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          _showEditPopup("Card Limit",
                              card.cardLimit.toString(), (value) {
                                setState(() {
                                  card.cardLimit =
                                      double.tryParse(value) ??
                                          card.cardLimit;
                                });
                              });
                        },
                      ),
                    ),
                    // Editable Status
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        title: const Text("Status"),
                        subtitle: Text(card.status),
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          _showStatusPopup(index);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
            // Bank Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bank Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoItem("Bank Name", bankName),
                _buildInfoItem("Account Number", accountNumber),
                _buildInfoItem("Branch Code", branchCode),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          _navigateFromBottomNav(index, context);
        },
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

  void _navigateFromBottomNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const transaction_lib.TransactionPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  Widget _buildCardInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            )),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(value, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  void _showEditPopup(
      String title, String currentValue, Function(String) onSave) {
    TextEditingController controller =
    TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showStatusPopup(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: "Active",
              groupValue: cards[index].status,
              title: const Text("Active"),
              onChanged: (val) {
                setState(() => cards[index].status = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: "Blocked",
              groupValue: cards[index].status,
              title: const Text("Blocked"),
              onChanged: (val) {
                setState(() => cards[index].status = val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
