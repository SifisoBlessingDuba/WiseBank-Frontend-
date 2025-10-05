import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_success_screen.dart';
import 'package:wisebank_frontend/models/account.dart';
import 'package:wisebank_frontend/services/api_service.dart';
import 'package:wisebank_frontend/services/globals.dart';
import 'package:wisebank_frontend/models/beneficiary.dart';

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
      TextEditingController(text: '00.00');
  final _formKey = GlobalKey<FormState>();

  // Typed beneficiary list, replacing map-based recipients
  List<Beneficiary> _beneficiaries = [];
  Beneficiary? _selectedBeneficiary;

  String _selectedCurrencySymbol = 'R';
  Account? _selectedAccount;
  List<Account> _userAccounts = [];

  late final ApiService _apiService;
  bool _isLoadingAccounts = true;
  String? _accountError;

  final List<String> _bankNames = [
    "FNB",
    "Absa",
    "Standard Bank",
    "Capitec",
    "Nedbank",
    "Discovery Bank",
    "TymeBank"
  ];
  String? _selectedBeneficiaryBank;

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
    Currency(name: 'Chinese Yuan', code: 'CNY', symbol: '¥'),
  ];

  late TextEditingController _beneficiaryNameController;
  late TextEditingController _beneficiaryAccountController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(); // Initialize ApiService
    _beneficiaryNameController = TextEditingController();
    _beneficiaryAccountController = TextEditingController();
    _fetchUserAccounts(); // Fetch accounts from API
    _loadSavedData(); // Load currency symbol
    _fetchBeneficiariesFromApi(); // Load beneficiaries from backend
  }

  Future<void> _fetchBeneficiariesFromApi() async {
    try {
      if (loggedInUserId.isEmpty) return;
      final items = await _apiService.getUserBeneficiaries(loggedInUserId);
      setState(() {
        _beneficiaries = items;
        if (_beneficiaries.isNotEmpty && _selectedBeneficiary == null) {
          _selectedBeneficiary = _beneficiaries.first;
          _selectedRecipient = _selectedBeneficiary!.name;
        }
      });
    } catch (e) {
      debugPrint('Failed to fetch beneficiaries: $e');
    }
  }

  Future<void> _fetchUserAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
      _accountError = null;
    });
    try {
      List<Account> accounts = [];
      // Prefer user-specific accounts
      if (loggedInUserId.isNotEmpty) {
        accounts = await _apiService.getUserAccounts(loggedInUserId);
      }
      // Fallback if nothing returned or userId not set
      if (accounts.isEmpty) {
        accounts = await _apiService.getAllAccounts();
      }

      setState(() {
        _userAccounts = accounts;
        if (_userAccounts.isNotEmpty) {
          // Preserve selection if still present; otherwise pick first
          if (_selectedAccount == null || !_userAccounts.any((a) => a.accountNumber == _selectedAccount!.accountNumber)) {
            _selectedAccount = _userAccounts.first;
          }
        } else {
          _selectedAccount = null;
        }
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _accountError = e.toString();
        _isLoadingAccounts = false;
        _userAccounts = [];
        _selectedAccount = null;
      });
      print('Error fetching accounts: $e');
    }
  }



  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCurrencySymbol = prefs.getString('selectedCurrencySymbol');

    setState(() {
      if (savedCurrencySymbol != null) {
        _selectedCurrencySymbol = savedCurrencySymbol;
      }
    });
  }

  Future<void> _saveSelectedCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrencySymbol', symbol);
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
    if (_isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accountError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Error loading accounts: \n$_accountError\nPlease try again later.',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userAccounts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2E6E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              'No accounts found.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
    }


    if (_selectedAccount == null && _userAccounts.isNotEmpty) {
      _selectedAccount = _userAccounts.first;
    } else if (_userAccounts.isNotEmpty && !_userAccounts.any((acc) => acc.accountNumber == _selectedAccount?.accountNumber)) {

      _selectedAccount = _userAccounts.first;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E6E),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Account>(
                  value: _selectedAccount,
                  isExpanded: true,
                  dropdownColor: Color(0xFF0A2E6E).withAlpha((0.95 * 255).round()),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: _userAccounts.map<DropdownMenuItem<Account>>((Account account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(

                        '${account.accountType} (${account.accountNumber})',
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
            ),
          const SizedBox(height: 15),
          if (_selectedAccount != null) ...[
            Text(
              _selectedAccount!.accountType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _selectedAccount!.accountNumber,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Available Balance:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '$_selectedCurrencySymbol${_selectedAccount!.accountBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
             const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Please select an account.", style: TextStyle(color: Colors.white70)),
                )
            ),
          ]
        ],
      ),
    );
  }

  void _showBeneficiaryActions(Beneficiary b) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit beneficiary'),
              onTap: () {
                Navigator.pop(context);
                _showEditBeneficiaryDialog(b);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete beneficiary'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteBeneficiary(b);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBeneficiary(Beneficiary b) async {
    if (b.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: Missing beneficiary ID.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete beneficiary?'),
        content: Text('This will remove ${b.name} (${b.accountNumber}).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await _apiService.deleteBeneficiary(b.id!);
    if (ok) {
      setState(() {
        _beneficiaries.removeWhere((x) => x.id == b.id);
        if (_selectedBeneficiary?.id == b.id) {
          _selectedBeneficiary = _beneficiaries.isNotEmpty ? _beneficiaries.first : null;
          _selectedRecipient = _selectedBeneficiary?.name ?? '';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beneficiary deleted.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete beneficiary.')),
      );
    }
  }

  void _showEditBeneficiaryDialog(Beneficiary b) {
    final nameCtrl = TextEditingController(text: b.name);
    final accCtrl = TextEditingController(text: b.accountNumber);
    String? bank = b.bankName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Beneficiary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'Account Number'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Bank'),
              value: bank,
              items: _bankNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => bank = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (b.id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot update: Missing beneficiary ID.')),
                );
                return;
              }
              try {
                final updated = await _apiService.updateBeneficiary(
                  id: b.id!,
                  name: nameCtrl.text.trim(),
                  accountNumber: accCtrl.text.trim(),
                  bankName: bank,
                );
                if (updated != null) {
                  setState(() {
                    final idx = _beneficiaries.indexWhere((x) => x.id == b.id);
                    if (idx >= 0) _beneficiaries[idx] = updated;
                    if (_selectedBeneficiary?.id == b.id) {
                      _selectedBeneficiary = updated;
                      _selectedRecipient = updated.name;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Beneficiary updated.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update beneficiary.')),
                  );
                }
              } catch (e) {
                final msg = e.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddBeneficiaryDialog() {
    _beneficiaryNameController.clear();
    _beneficiaryAccountController.clear();
    _selectedBeneficiaryBank = null;

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
                  initialValue: _selectedBeneficiaryBank,
                  hint: const Text('Select Bank'),
                  isExpanded: true,
                  items: _bankNames.map((String bankName) {
                    return DropdownMenuItem<String>(
                      value: bankName,
                      child: Text(bankName),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_selectedBeneficiaryBank == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select beneficiary bank.')),
                    );
                    return;
                  }

                  try {
                    final created = await _apiService.createBeneficiary(
                      userId: loggedInUserId,
                      name: _beneficiaryNameController.text.trim(),
                      accountNumber: _beneficiaryAccountController.text.trim(),
                      bankName: _selectedBeneficiaryBank!,
                    );

                    if (created != null) {
                      setState(() {
                        _beneficiaries.insert(0, created);
                        _selectedBeneficiary = created;
                        _selectedRecipient = created.name;
                      });
                      // Re-fetch from backend to confirm persistence and normalize
                      await _fetchBeneficiariesFromApi();
                      if (mounted) Navigator.of(context).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Beneficiary added successfully.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add beneficiary.')),
                      );
                    }
                  } catch (e) {
                    final msg = e.toString().replaceFirst('Exception: ', '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
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
        itemCount: 1 + _beneficiaries.length, // Add tile + beneficiaries
        itemBuilder: (context, index) {
          if (index == 0) {
            // Add tile
            return GestureDetector(
              onTap: _showAddBeneficiaryDialog,
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.blue.withAlpha((0.3 * 255).round()),
                        width: 1.5)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                    SizedBox(height: 8),
                    Text('Add', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }

          final b = _beneficiaries[index - 1];
          final bool isSelected = _selectedBeneficiary?.accountNumber == b.accountNumber;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBeneficiary = b;
                _selectedRecipient = b.name;
              });
            },
            onLongPress: () {
              _showBeneficiaryActions(b);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withAlpha((0.2 * 255).round())
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 1.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors
                        .primaries[(index - 1) % Colors.primaries.length]
                        .withAlpha((0.8 * 255).round()),
                    child: Text(
                      (b.name.isNotEmpty ? b.name[0] : '?').toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b.name,
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
              color: Colors.grey.withAlpha((0.1 * 255).round()),
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
      onPressed: _isSubmitting ? null : () async {
        if (_selectedAccount == null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an account to send from.')),
          );
          return;
        }
        if (_selectedBeneficiary == null) {
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

        final amountToSend = double.tryParse(_amountController.text)!;
        if (_selectedAccount!.accountBalance < amountToSend) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient balance.')),
          );
          return;
        }

        setState(() { _isSubmitting = true; });
        try {
          final ok = await _apiService.withdrawFromAccountNumber(
            userId: loggedInUserId,
            accountNumber: _selectedAccount!.accountNumber,
            amount: amountToSend,
          );

          if (!ok) {
            if (!mounted) return;
            setState(() { _isSubmitting = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transfer failed. Please try again.')),
            );
            return;
          }

          // Refresh accounts from backend to reflect persisted balance
          await _fetchUserAccounts();

          if (!mounted) return;
          setState(() { _isSubmitting = false; });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionSuccessScreen(
                amount: amountToSend,
                currencySymbol: _selectedCurrencySymbol,
                recipientName: _selectedBeneficiary!.name,
                fromAccountName: _selectedAccount!.accountType,
                fromAccountNumber: _selectedAccount!.accountNumber,
                transactionTime: DateTime.now(),
              ),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          setState(() { _isSubmitting = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transfer error: $e')),
          );
        }
      },
      child: _isSubmitting
        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : const Text('Send Money', style: TextStyle(color: Colors.white)),
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
