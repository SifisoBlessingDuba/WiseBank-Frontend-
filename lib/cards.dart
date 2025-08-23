// cards_page.dart
import 'package:flutter/material.dart';

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
}

class _CardsPageState extends State<CardsPage> {
  List<CardModel> cards = [
    CardModel(
      cardHolder: "Wiseman Bedesho",
      cardNumber: "1234 5678 9012 3456",
      expiryDate: "12/25",
      cvv: "123",
      issueDate: "01/01/2023",
      cardType: "Credit",
      cardLimit: 5000,
      status: "Active",
    ),
    CardModel(
      cardHolder: "Wiseman Bedesho",
      cardNumber: "9876 5432 1098 7654",
      expiryDate: "06/26",
      cvv: "456",
      issueDate: "01/06/2023",
      cardType: "Debit",
      cardLimit: 10000,
      status: "Blocked",
    ),
  ];

  // Bank Info (can also be per card if needed)
  String bankName = "WiseBank";
  String accountNumber = "1234567890";
  String branchCode = "012345";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCardInfoColumn("Card Holder", card.cardHolder),
                                _buildCardInfoColumn("Expiry", card.expiryDate),
                                _buildCardInfoColumn("CVV", card.cvv),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCardInfoColumn("Issue Date", card.issueDate),
                                _buildCardInfoColumn("Card Type", card.cardType),
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
                          _showEditPopup(
                              "Card Limit", card.cardLimit.toString(), (value) {
                            setState(() {
                              card.cardLimit = double.tryParse(value) ?? card.cardLimit;
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
    );
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

  void _showEditPopup(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

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
