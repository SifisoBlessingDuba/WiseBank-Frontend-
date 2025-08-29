import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Transaction model
class Transaction {
  final String title;
  final String amount;
  final String date;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  // Store transactions here
  List<Transaction> transactions = [
    Transaction(
        title: "Soccer",
        amount: "-R150.00",
        date: "Today, 09:30 AM",
        isIncome: false),
    Transaction(
        title: "Bankseta",
        amount: "+R5,500.00",
        date: "25 Aug, 00:00",
        isIncome: true),
    Transaction(
        title: "Sifiso Blessing loan",
        amount: "-R200.00",
        date: "23 Aug, 18:45",
        isIncome: false),
    Transaction(
        title: "Withdrawal",
        amount: "-R2000",
        date: "21 Aug, 12:32",
        isIncome: false),
    Transaction(
        title: "Salary Deposit",
        amount: "+R8,500.00",
        date: "1 Aug, 12:00",
        isIncome: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Transaction"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Transaction Form
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Enter Transaction Details",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                        prefixText: "R ",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        labelText: "Card Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: "Expiry (MM/YY)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                            maxLength: 5,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    ElevatedButton(
                      onPressed: () {
                        if (amountController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            cardNumberController.text.isNotEmpty &&
                            expiryController.text.isNotEmpty &&
                            cvvController.text.isNotEmpty) {

                          final now = DateTime.now();
                          final formattedDate = DateFormat("dd MMM, HH:mm").format(now);


                          final newTransaction = Transaction(
                            title: descriptionController.text,
                            amount: "R${amountController.text}",
                            date: formattedDate,
                            isIncome: !amountController.text.startsWith("-"),
                          );

                          setState(() {
                            transactions.insert(0, newTransaction);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Transaction of R${amountController.text} for ${descriptionController.text} submitted!",
                              ),
                            ),
                          );

                          // Clear inputs
                          amountController.clear();
                          descriptionController.clear();
                          cardNumberController.clear();
                          expiryController.clear();
                          cvvController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please fill in all fields"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Submit Transaction"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.0),
            // Transaction History
            Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),

            // Build transactions dynamically
            Column(
              children: transactions
                  .map((tx) => _transactionTile(
                  tx.title, tx.amount, tx.date, tx.isIncome))
                  .toList(),
            ),
          ],
        ),
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
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}