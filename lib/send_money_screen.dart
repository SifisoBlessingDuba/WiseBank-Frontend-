import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// // Added import

// Define the Account class
class Account {
  final String id;
  final String accountName; // e.g., "Personal Cheque"
  final String accountNumber; // e.g., "123456789"
  double balance;
  final String accountType; // e.g., "Cheque", "Savings", "Business"

  Account({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.balance,
    required this.accountType,
  });
}

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
  final _formKey = GlobalKey<FormState>(); // For beneficiary form validation

  List<Map<String, dynamic>> _recipients = [
    {'name': 'Add', 'icon': Icons.add},
  ];

  String _selectedCurrencySymbol = 'R'; // Default currency symbol
  Account? _selectedAccount; // Currently selected user account
  List<Account> _userAccounts = []; // List of user's accounts

  final List<String> _bankNames = [
    "FNB",
    "Absa",
    "Standard Bank",
    "Capitec",
    "Nedbank",
    "Discovery Bank",
    "TymeBank"
  ];
  String? _selectedBeneficiaryBank; // For the dropdown in add beneficiary dialog

  final List<Currency> _currencies = [
    Currency(name: 'South African Rand', code: 'ZAR', symbol: 'R'),
    Currency(name: 'Mozambican Metical', code: 'MZN', symbol: 'MZN'),
    Currency(name: 'US Dollar', code: 'USD', symbol: '\$'),
    Currency(name: 'Euro', code: 'EUR', symbol: '€'),
    Currency(name: 'British Pound', code: 'GBP', symbol: '£'),
    // Add more currencies as needed
  ];

  late TextEditingController _beneficiaryNameController;
  late TextEditingController _beneficiaryAccountController;

  @override
  void initState() {
    super.initState();
    _beneficiaryNameController = TextEditingController();
    _beneficiaryAccountController = TextEditingController();
    _initializeUserAccounts(); // Initialize sample accounts
    _loadSavedData();
  }

  void _initializeUserAccounts() {
    _userAccounts = [
      Account(
          id: '1',
          accountName: 'Personal Cheque',
          accountNumber: '123456789',
          balance: 15000.75,
          accountType: 'Cheque'),
      Account(
          id: '2',
          accountName: 'Business Account',
          accountNumber: '987654321',
          balance: 75000.50,
          accountType: 'Business'),
      Account(
          id: '3',
          accountName: 'Investment Portfolio',
          accountNumber: '112233445',
          balance: 250000.00,
          accountType: 'Investment'),
    ];
    if (_userAccounts.isNotEmpty) {
      _selectedAccount = _userAccounts.first; // Default to the first account
    }
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
        if (_recipients.length <= 1) { // if only 'Add' button exists or it's empty
          _recipients.addAll([
            {'name': 'Sifiso', 'avatar': 'S', 'accountNumber': '000000001', 'bankName': 'FNB'},
            {'name': 'Itumeleng', 'avatar': 'I', 'accountNumber': '000000002', 'bankName': 'Capitec'},
          ]);
        }
      } else {
         // Default recipients if nothing is saved
        _recipients.addAll([
            {'name': 'Sifiso', 'avatar': 'S', 'accountNumber': '000000001', 'bankName': 'FNB'},
            {'name': 'Itumeleng', 'avatar': 'I', 'accountNumber': '000000002', 'bankName': 'Capitec'},
        ]);
      }
      if (_selectedRecipient.isEmpty && _recipients.length > 1) {
         // Select the first actual recipient if none is selected and list is not empty
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
                  const SizedBox(height: 79), // For spacing from bottom button
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
    if (_selectedAccount == null && _userAccounts.isNotEmpty) {
      _selectedAccount = _userAccounts.first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E6E), // Wise Bank blue
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column wrap content
        children: <Widget>[
          const Text(
            'FROM ACCOUNT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_userAccounts.isNotEmpty)
            Container( // Wrapped DropdownButtonHideUnderline with a Container
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Optional padding for the container
              decoration: BoxDecoration( // Applied decoration to the Container
                border: Border.all(color: Colors.white54, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Account>(
                  value: _selectedAccount, // Ensure this value is one of the items or null
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0A2E6E).withOpacity(0.95), // Slightly transparent for effect
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: _userAccounts.map<DropdownMenuItem<Account>>((Account account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(
                        '${account.accountName} (${account.accountType})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (Account? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAccount = newValue;
                      });
                    }
                  },
                  hint: const Text("Select Account", style: TextStyle(color: Colors.white70)),
                ),
              ),
            )
          else
            const Text(
              'No accounts available to select.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          const SizedBox(height: 15),
          if (_selectedAccount != null) ...[
            Text(
              _selectedAccount!.accountName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20, // Adjusted size
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _selectedAccount!.accountNumber,
              style: const TextStyle(color: Colors.white70, fontSize: 14), // Adjusted size
            ),
            const SizedBox(height: 10),
            const Text(
              'Available Balance:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            // DEBUG PRINT for display card
            if(_selectedAccount?.balance != null) Text('DisplayCard rendering balance: ${_selectedAccount!.balance}', style: const TextStyle(color: Colors.red)), // TEMPORARY DEBUG
            Text(
              '$_selectedCurrencySymbol${_selectedAccount!.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26, // Adjusted size
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (_userAccounts.isEmpty && _selectedAccount == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: const Text(
                'Please select an account from the dropdown above.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          ]
           else if (_selectedAccount == null) ...[ // If accounts exist but none is selected (should not happen with current init logic)
             const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Loading account details...", style: TextStyle(color: Colors.white70)),
                )
            ),
          ]
        ],
      ),
    );
  }

  void _showAddBeneficiaryDialog() {
    _beneficiaryNameController.clear();
    _beneficiaryAccountController.clear();
    _selectedBeneficiaryBank = null; // Reset selected bank

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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Beneficiary Bank'),
                  value: _selectedBeneficiaryBank, 
                  hint: const Text('Select Bank'),
                  isExpanded: true,
                  items: _bankNames.map((String bankName) {
                    return DropdownMenuItem<String>(
                      value: bankName,
                      child: Text(bankName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // This setState is crucial if the UI needs to react to selection
                    // For now, it's just updating the state variable.
                     _selectedBeneficiaryBank = newValue;
                  },
                  validator: (value) => value == null ? 'Please select a bank' : null,
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
                  if (_selectedBeneficiaryBank == null) { // Double check, though validator should catch it
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select beneficiary bank.')),
                    );
                    return;
                  }
                  setState(() {
                    final newRecipientName = _beneficiaryNameController.text;
                    final newRecipient = {
                      'name': newRecipientName,
                      'avatar': newRecipientName.isNotEmpty ? newRecipientName[0].toUpperCase() : '?',
                      'accountNumber': _beneficiaryAccountController.text,
                      'bankName': _selectedBeneficiaryBank, 
                    };
                    _recipients.add(newRecipient);
                    _selectedRecipient = newRecipientName; // Auto-select the newly added recipient
                    _saveRecipients();
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
                      _saveSelectedCurrency(currency.symbol);
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
                        recipient['avatar'] ?? '?', 
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    recipient['name'] ?? 'N/A', 
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
          border: Border.all(color: Colors.grey[300]!) , boxShadow: [
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
                _selectedCurrencySymbol, 
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
        if (_selectedAccount == null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an account to send from.')),
          );
          return;
        }
        if (_selectedRecipient.isEmpty || _selectedRecipient == 'Add') { // _selectedRecipient is a String
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

        final amountToSend = double.tryParse(_amountController.text);
        // Find the actual recipient Map to get the name for the success screen
        final recipientMap = _recipients.firstWhere((r) => r['name'] == _selectedRecipient, orElse: () => {});


        if (amountToSend != null && _selectedAccount!.balance >= amountToSend) {
            setState(() {
                // DEBUG PRINT for balance deduction
                print('Balance before deduction: ${_selectedAccount!.balance}');
                _selectedAccount!.balance -= amountToSend;
                print('Balance after deduction: ${_selectedAccount!.balance}');
            });
            
            // Navigate to TransactionSuccessScreen
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => TransactionSuccessScreen(
            //       amount: amountToSend,
            //       currencySymbol: _selectedCurrencySymbol, // Using the existing symbol
            //       recipientName: recipientMap['name']?.toString() ?? 'N/A', // Get name from map
            //       fromAccountName: _selectedAccount!.accountName,
            //       fromAccountNumber: _selectedAccount!.accountNumber,
            //       transactionTime: DateTime.now(),
            //     ),
            //   ),
            // );

        } else if (amountToSend != null) {
             ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient balance.')),
          );
          return;
        }
        
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
