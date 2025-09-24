import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Transaction model
class Transaction {
  final String title;
  final String amount;
  final String date;
  final bool isIncome;
  
  Transaction({
  const Transaction({
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
        title: "Salary Payment",
        amount: "+R8,500.00",
        date: "1 Aug, 12:00",
        isIncome: true),
class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  // Predefined 20 transactions (chronological order: oldest first)
  final List<Transaction> transactions = const [
    Transaction(title: "July Rent", amount: "-R5,000.00", date: "1 Jul, 09:00", isIncome: false),
    Transaction(title: "July Salary", amount: "+R8,000.00", date: "15 Jul, 12:00", isIncome: true),
    Transaction(title: "Grocery", amount: "-R450.00", date: "17 Jul, 18:45", isIncome: false),
    Transaction(title: "Gym Membership", amount: "-R300.00", date: "20 Jul, 07:30", isIncome: false),
    Transaction(title: "Electricity Bill", amount: "-R1,200.00", date: "25 Jul, 14:00", isIncome: false),
    Transaction(title: "July Bonus", amount: "+R1,500.00", date: "30 Jul, 16:00", isIncome: true),
    Transaction(title: "August Salary", amount: "+R8,500.00", date: "1 Aug, 12:00", isIncome: true),
    Transaction(title: "Withdrawal", amount: "-R2,000.00", date: "2 Aug, 09:30", isIncome: false),
    Transaction(title: "Mali ka Ramaphosa", amount: "+R350.00", date: "2 Aug, 18:45", isIncome: true),
    Transaction(title: "Soccer", amount: "-R150.00", date: "3 Aug, 09:30", isIncome: false),
    Transaction(title: "Bankseta", amount: "+R5,500.00", date: "5 Aug, 00:00", isIncome: true),
    Transaction(title: "Sifiso Blessing Loan", amount: "-R200.00", date: "7 Aug, 18:45", isIncome: false),
    Transaction(title: "Water Bill", amount: "-R350.00", date: "8 Aug, 10:15", isIncome: false),
    Transaction(title: "Netflix", amount: "-R120.00", date: "9 Aug, 20:00", isIncome: false),
    Transaction(title: "Spotify", amount: "-R99.00", date: "10 Aug, 08:00", isIncome: false),
    Transaction(title: "Deposit", amount: "+R1,000.00", date: "12 Aug, 11:00", isIncome: true),
    Transaction(title: "Withdrawal", amount: "-R500.00", date: "14 Aug, 14:30", isIncome: false),
    Transaction(title: "Uber Ride", amount: "-R250.00", date: "16 Aug, 19:00", isIncome: false),
    Transaction(title: "Salary Payment", amount: "+R8,500.00", date: "18 Aug, 12:00", isIncome: true),
    Transaction(title: "Amazon Purchase", amount: "-R1,200.00", date: "20 Aug, 15:45", isIncome: false),

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
    // Reverse the list so August is at the top
    final reversedTransactions = transactions.reversed.toList();

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
      body: Scrollbar(
        thumbVisibility: true, // shows the scrollbar thumb
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reversedTransactions.length,
          itemBuilder: (context, index) {
            final tx = reversedTransactions[index];
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
                    tx.amount,
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
      ),
    );
  }
  }
