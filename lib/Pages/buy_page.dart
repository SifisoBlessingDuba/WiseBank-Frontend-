import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/api_service.dart';
import 'purchase_success_page.dart';
import 'package:wisebank_frontend/services/globals.dart' as globals;

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  Account? _selectedAccount;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  String selectedItemType = '';
  String? selectedProvider;

  final List<String> itemTypes = [
    "Airtime",
    "Data",
    "Voucher",
    "Gift Card",
  ];

  final Map<String, List<String>> providers = {
    "Airtime": ["MTN", "Vodacom", "Telkom", "Cell C"],
    "Data": ["MTN", "Vodacom", "Telkom", "Rain"],
    "Voucher": ["Steam", "Google Play", "iTunes"],
    "Gift Card": ["Amazon", "Takealot", "Spotify"],
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
      final accounts = await _api_service_getAllAccountsSafe();
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
      print('Error fetching accounts: $e');
    }
  }

  // small wrapper so we can catch and rethrow properly while logging
  Future<List<Account>> _api_service_getAllAccountsSafe() async {
    try {
      return await _apiService.getAllAccounts();
    } catch (e) {
      print("Error in ApiService.getAllAccounts(): $e");
      rethrow;
    }
  }

  void _buyItem() async {
    final amountText = amountController.text.trim();
    final reference = referenceController.text.trim();

    if (_selectedAccount == null) {
      _showMessage("Please select an account.");
      return;
    }

    if (selectedItemType.isEmpty) {
      _showMessage("Please select an item type.");
      return;
    }

    if (selectedProvider == null) {
      _showMessage("Please select a provider.");
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

    // Quick client-side balance check
    if (amount > _selectedAccount!.accountBalance) {
      _showMessage("Insufficient balance.");
      return;
    }

    // Determine an identifier to send to the backend.
    // Prefer accountId (server id), fallback to accountNumber if accountId is empty.
    final accountIdCandidate = (_selectedAccount!.accountId ?? '').trim();
    final accountNumberCandidate = (_selectedAccount!.accountNumber ?? '').trim();

    String accountIdentifier = '';
    if (accountIdCandidate.isNotEmpty) {
      accountIdentifier = accountIdCandidate;
    } else if (accountNumberCandidate.isNotEmpty) {
      accountIdentifier = accountNumberCandidate;
    } else {
      // As a last resort, try to use the user-entered reference if it looks like an account number
      final refDigits = reference.replaceAll(RegExp(r'\D'), '');
      if (refDigits.length >= 4) {
        accountIdentifier = refDigits;
        print("DEBUG _buyItem: Using reference fallback as account identifier: $accountIdentifier");
      } else {
        _showMessage("Selected account has no account identifier. Please choose another account.");
        print("DEBUG _buyItem: No accountId/accountNumber available on selectedAccount: ${_selectedAccount.toString()}");
        return;
      }
    }

    try {
      // Debug print of what we're about to send
      print("DEBUG _buyItem: sending withdrawAmount(accountId: '$accountIdentifier', newBalance: $amount)");

      // CALL the existing ApiService method (do NOT change ApiService)
      final success = await _apiService.withdrawAmount(
        accountId: accountIdentifier,
        newBalance: amount, // send the amount to withdraw (your service expects this param)
      );

      print("DEBUG _buyItem: withdrawAmount returned: $success");

      if (!success) {
        _showMessage("Purchase failed: insufficient balance or server rejected request.");
        return;
      }

      // Optimistic UI update - subtract amount locally for immediate feedback
      setState(() {
        _selectedAccount!.accountBalance -= amount;
      });

      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchaseSuccessScreen(
            amount: amount,
            currencySymbol: "R",
            itemType: selectedItemType,
            provider: selectedProvider!,
            accountUsed: '${_selectedAccount!.accountType} (${_selectedAccount!.accountNumber})',
            reference: reference,
            purchaseTime: DateTime.now(),
          ),
        ),
      ).then((_) {
        // Reset fields after returning
        amountController.clear();
        referenceController.clear();
        setState(() {
          selectedItemType = '';
          selectedProvider = null;
          _selectedAccount = null;
        });
      });
    } catch (e) {
      print("ERROR _buyItem: exception -> $e");
      _showMessage("Purchase failed: $e");
    }
  }



  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.lightBlueAccent),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Items"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: _isLoadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : _accountError != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Error loading accounts:\n$_accountError\nPlease try again later.',
            style: const TextStyle(color: Colors.red, fontSize: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Available Balance:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "R${_selectedAccount!.accountBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Select Item Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: itemTypes.map((item) {
                final isSelected = selectedItemType == item;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItemType = item;
                      selectedProvider = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? Colors.lightBlue[200] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.lightBlueAccent!, width: 1.2),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (selectedItemType.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Provider",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedProvider,
                    hint: const Text("Choose provider"),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: providers[selectedItemType]!
                        .map((prov) => DropdownMenuItem<String>(
                      value: prov,
                      child: Text(prov),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvider = value;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
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
                labelText: (selectedItemType == "Airtime" ||
                    selectedItemType == "Data")
                    ? "Phone Number"
                    : "Email / Reference",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _buyItem,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text(
                  "Buy Now",
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
}
