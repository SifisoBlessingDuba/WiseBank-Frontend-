import 'package:flutter/material.dart';
import 'package:wisebank_frontend/services/globals.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import 'payment_success_page.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String selectedBill = '';
  Account? _selectedAccount;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  final List<String> bills = [
    "Water",
    "Electricity",
    "DSTV",
    "Telkom/Internet",
    "Gas",
    "Rates & Taxes",
    "Insurance",
    "Other"
  ];

  final Map<String, String> billDescriptions = {
    "Water": "Pay your municipal water bill to ensure uninterrupted supply.",
    "Electricity": "Pay your electricity bill to avoid load-shedding or penalties.",
    "DSTV": "Pay your DSTV subscription to continue enjoying your entertainment.",
    "Telkom/Internet": "Pay your Telkom or Internet provider for connectivity.",
    "Gas": "Pay your gas bill for cooking or heating purposes.",
    "Rates & Taxes": "Pay your municipal rates and property taxes.",
    "Insurance": "Pay your home, vehicle or personal insurance premiums.",
    "Other": "Pay other miscellaneous household bills.",
  };

  List<Account> _userAccounts = [];
  bool _isLoadingAccounts = true;
  String? _accountError;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchUserAccounts();
  }

  Future<void> _fetchUserAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
      _accountError = null;
    });
    try {
      final accounts = await _apiService.getAllAccounts();
      setState(() {
        _userAccounts = accounts;
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _accountError = e.toString();
        _userAccounts = [];
        _isLoadingAccounts = false;
      });
    }
  }

  Future<void> _payBill() async {
    final amountText = amountController.text.trim();
    final reference = referenceController.text.trim();

    if (selectedBill.isEmpty) {
      _showMessage("Please select a bill type.");
      return;
    }

    if (_selectedAccount == null) {
      _showMessage("Please select an account.");
      return;
    }

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showMessage("Please enter a valid amount.");
      return;
    }

    final amount = double.parse(amountText);

    if (amount <= 0) {
      _showMessage("Amount must be greater than 0.");
      return;
    }

    try {
      final success = await _apiService.withdrawAmount(
        accountId: _selectedAccount!.accountId,
        newBalance: amount,
      );

      if (!success) {
        _showMessage("Insufficient balance or withdrawal failed.");
        return;
      }

      setState(() {
        _selectedAccount!.accountBalance -= amount;
      });

      // Create notification after successful payment
      await _apiService.createNotification({
        "title": "Bill Payment Successful",
        "message": "You paid R${amount.toStringAsFixed(2)} for $selectedBill. Reference: $reference",
        "notificationType": "Payment",
        "isRead": "No",
        "timeStamp": DateTime.now().toIso8601String(),
        "user": {"idNumber": loggedInUserId} // adjust according to your user model
      });

      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillPaymentSuccessScreen(
            amount: amount,
            currencySymbol: "R",
            billType: selectedBill,
            accountUsed:
            '${_selectedAccount!.accountType} (${_selectedAccount!.accountNumber})',
            reference: reference,
            paymentTime: DateTime.now(),
          ),
        ),
      ).then((_) {
        amountController.clear();
        referenceController.clear();
        setState(() {
          selectedBill = '';
          _selectedAccount = null;
        });
      });
    } catch (e) {
      _showMessage("Payment failed: $e");
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Bills"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        elevation: 2,
      ),
      body: _isLoadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : _accountError != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error loading accounts:\n$_accountError\nPlease try again later.',
            style:
            const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : _userAccounts.isEmpty
          ? const Center(child: Text('No accounts found.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Account",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<Account>(
                  value: _selectedAccount,
                  hint: const Text("Choose account"),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _userAccounts.map((account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(account.accountType),
                    );
                  }).toList(),
                  onChanged: (Account? value) {
                    setState(() {
                      _selectedAccount = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedAccount != null)
              Card(
                color: Colors.lightBlue[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Available Balance:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "R${_selectedAccount!.accountBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Select Bill Type",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: bills.map((bill) {
                final isSelected = bill == selectedBill;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBill = bill;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.lightBlue[200]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.lightBlueAccent!,
                          width: 1.2),
                    ),
                    child: Text(
                      bill,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            if (selectedBill.isNotEmpty)
              Card(
                color: Colors.lightBlue[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    billDescriptions[selectedBill] ?? "",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: InputDecoration(
                labelText: "Amount (R)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixText: "R ",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: "Reference / Account Number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _payBill,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    super.dispose();
  }
}
