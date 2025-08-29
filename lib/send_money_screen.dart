import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Currency {
  final String name;
  final String code;
  final String symbol;

  Currency({required this.name, required this.code, required this.symbol});
}

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String _selectedRecipient = '';
  final TextEditingController _amountController =
      TextEditingController(text: '40.00');
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _recipients = [
    {'name': 'Add', 'icon': Icons.add},

  ];

  String _selectedCurrencySymbol = 'R';

  final List<Currency> _currencies = [
    Currency(name: 'South African Rand', code: 'ZAR', symbol: 'R'),
    Currency(name: 'Mozambican Metical', code: 'MZN', symbol: 'MZN'),
    Currency(name: 'US Dollar', code: 'USD', symbol: '\$'),
    Currency(name: 'Euro', code: 'EUR', symbol: '€'),
    Currency(name: 'British Pound', code: 'GBP', symbol: '£'),
    Currency(name: 'Japanese Yen', code: 'JPY', symbol: '¥'),
    Currency(name: 'Australian Dollar', code: 'AUD', symbol: 'A\$'),
    Currency(name: 'Canadian Dollar', code: 'CAD', symbol: 'C\$'),
    Currency(name: 'Swiss Franc', code: 'CHF', symbol: 'CHF'),
    Currency(name: 'Chinese Yuan Renminbi', code: 'CNY', symbol: '¥'),
    Currency(name: 'Indian Rupee', code: 'INR', symbol: '₹'),
    Currency(name: 'Brazilian Real', code: 'BRL', symbol: 'R\$'),
    Currency(name: 'Russian Ruble', code: 'RUB', symbol: '₽'),
    Currency(name: 'Kenyan Shilling', code: 'KES', symbol: 'KSh'),
    Currency(name: 'Nigerian Naira', code: 'NGN', symbol: '₦'),
  ];

  // Controllers for the beneficiary dialog
  late TextEditingController _beneficiaryNameController;
  late TextEditingController _beneficiaryAccountController;

  @override
  void initState() {
    super.initState();
    _beneficiaryNameController = TextEditingController();
    _beneficiaryAccountController = TextEditingController();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCurrencySymbol = prefs.getString('selectedCurrencySymbol');
    final String? savedRecipientsString = prefs.getString('recipients');

    setState(() {
      if (savedCurrencySymbol != null) {
        _selectedCurrencySymbol = savedCurrencySymbol;
      }
      if (savedRecipientsString != null) {
        final List<dynamic> decodedRecipients = jsonDecode(savedRecipientsString);
        _recipients = [
          {'name': 'Add', 'icon': Icons.add}, // Keep the Add button
          ...decodedRecipients.cast<Map<String, dynamic>>(),
        ];

        if (_recipients.length <= 1) {
           _recipients.addAll([
            {'name': 'Sifiso', 'avatar': 'S', 'accountNumber': '000000001'},
            {'name': 'Itumeleng', 'avatar': 'I', 'accountNumber': '000000002'},
            {'name': 'Fatso', 'avatar': 'F', 'accountNumber': '000000003'},
            {'name': 'Laeeqah', 'avatar': 'L', 'accountNumber': '000000004'},
          ]);
        }
      } else {

        _recipients.addAll([
            {'name': 'Sifiso', 'avatar': 'S', 'accountNumber': '000000001'},
            {'name': 'Itumeleng', 'avatar': 'I', 'accountNumber': '000000002'},
            {'name': 'Fatso', 'avatar': 'F', 'accountNumber': '000000003'},
            {'name': 'Laeeqah', 'avatar': 'L', 'accountNumber': '000000004'},
        ]);
      }

      if (_selectedRecipient.isEmpty && _recipients.length > 1) {
        _selectedRecipient = _recipients[1]['name']!;
      }
    });
  }

  Future<void> _saveSelectedCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrencySymbol', symbol);
  }

  Future<void> _saveRecipients() async {
    final prefs = await SharedPreferences.getInstance();
    // Exclude the 'Add' button from saving
    final List<Map<String, dynamic>> recipientsToSave =
        _recipients.where((r) => r['name'] != 'Add').toList();
    await prefs.setString('recipients', jsonEncode(recipientsToSave));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDisplayCard(),
                  const SizedBox(height: 30),
                  Text(
                    'Send to',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  _buildRecipientsList(),
                  const SizedBox(height: 30),
                  _buildAmountEntry(),
                  const SizedBox(height: 79),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildSendMoneyButton(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDisplayCard() {
    return Container(
      height: 200.0,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF0A2E6E),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/logo.png', height: 40),
              Image.asset('assets/mastercard_logo.png', height: 30),
            ],
          ),
          Text(
            '4562 1122 4595 7852', // Example card number
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
                fontFamily: 'monospace'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Cardholder name',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text('Mr I Wiseman',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Expiry date',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text('12/30',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBeneficiaryDialog() {
    _beneficiaryNameController.clear();
    _beneficiaryAccountController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Beneficiary'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _beneficiaryNameController,
                  decoration: const InputDecoration(labelText: 'Beneficiary Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _beneficiaryAccountController,
                  decoration: const InputDecoration(labelText: 'Account Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an account number';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid account number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    final newRecipientName = _beneficiaryNameController.text;
                    final newRecipient = {
                      'name': newRecipientName,
                      'avatar': newRecipientName.isNotEmpty ? newRecipientName[0].toUpperCase() : '?',
                      'accountNumber': _beneficiaryAccountController.text,
                    };
                    _recipients.add(newRecipient);
                    _selectedRecipient = newRecipientName;
                    _saveRecipients(); // Save after adding
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCurrencySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _currencies.length,
              itemBuilder: (BuildContext context, int index) {
                final currency = _currencies[index];
                return ListTile(
                  title: Text('${currency.name} (${currency.symbol})'),
                  onTap: () {
                    setState(() {
                      _selectedCurrencySymbol = currency.symbol;
                      _saveSelectedCurrency(currency.symbol); // Save after selection
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipientsList() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recipients.length,
        itemBuilder: (context, index) {
          final recipient = _recipients[index];
          bool isSelected = _selectedRecipient == recipient['name'];
          return GestureDetector(
            onTap: () {
              if (recipient['name'] == 'Add') {
                _showAddBeneficiaryDialog();
              } else {
                setState(() {
                  _selectedRecipient = recipient['name']!;
                });
              }
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 1.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (recipient['icon'] != null)
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: Icon(recipient['icon'],
                          color: Colors.blueAccent, size: 28),
                    )
                  else
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors
                          .primaries[index % Colors.primaries.length]
                          .withOpacity(0.8),
                      child: Text(
                        recipient['avatar']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    recipient['name']!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountEntry() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Your Amount',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _selectedCurrencySymbol, // Use the state variable here
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _showCurrencySelectionDialog();
                },
                child: const Text(
                  'Change Currency?',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendMoneyButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () {
        // ignore: avoid_print
        print(
            'Send Money tapped with amount: ${_amountController.text} ($_selectedCurrencySymbol) to $_selectedRecipient');
        // TODO: Implement actual send money logic
        if (_selectedRecipient.isEmpty || _selectedRecipient == 'Add') {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a recipient.')),
          );
          return;
        }
         if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null || double.parse(_amountController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount.')),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sending ${_amountController.text} $_selectedCurrencySymbol to $_selectedRecipient')),
        );
      },
      child: const Text('Send Money', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _beneficiaryNameController.dispose();
    _beneficiaryAccountController.dispose();
    super.dispose();
  }
}
