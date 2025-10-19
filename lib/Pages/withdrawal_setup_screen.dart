import 'package:flutter/material.dart';
import '../services/globals.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'confirmation_page.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class AccountModel {
  String? accountId;
  String accountNumber;
  double balance;
  String accountType;

  AccountModel({
    this.accountId,
    required this.accountNumber,
    required this.balance,
    required this.accountType,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    dynamic rawBalance = json['accountBalance'] ?? json['balance'] ?? 0;

    // If balance is wrapped in an object, try common fields
    if (rawBalance is Map) {
      rawBalance = rawBalance['amount'] ?? rawBalance['value'] ?? rawBalance['balance'] ?? 0;
    }

    double parseBalance(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final match = RegExp(r'-?[0-9]+(?:[.,][0-9]+)?').firstMatch(value);
        if (match != null) {
          final numeric = match.group(0)!.replaceAll(',', '');
          return double.tryParse(numeric) ?? 0;
        }
      }
      return 0;
    }

    final dynamic rawId = json['accountId'] ?? json['id'] ?? json['accountID'] ?? json['account_id'] ?? json['_id'];

    return AccountModel(
      accountId: rawId?.toString(),
      accountNumber: (json['accountNumber'] ?? json['number'] ?? json['accountNo'] ?? '').toString(),
      balance: parseBalance(rawBalance),
      accountType: (json['accountType'] ?? json['type'] ?? 'Unknown').toString(),
    );
  }
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final ApiService _api = ApiService();
  List<AccountModel> accounts = [];
  String userName = "";
  String phoneNumber = "";
  bool isLoading = true;
  int selectedAccountIndex = 0;

  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchUserInfo();
    await fetchAccounts();
    setState(() => isLoading = false);
  }

  Future<void> fetchUserInfo() async {
    try {
      if (loggedInUserId.isEmpty) return;
      final api = ApiService();
      final Map<String, dynamic> data = await api.getUserDetails(loggedInUserId);
      setState(() {
        userName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        phoneNumber = (data['phoneNumber'] ?? '').toString();
      });
    } catch (e) {
      debugPrint("fetchUserInfo (ApiService) error: $e");
    }
  }

  Future<void> fetchAccounts() async {
    // Prefer authenticated ApiService endpoints (Dio + interceptor) so the
    // Authorization header is consistently applied. Fallback to all accounts
    // if user-specific endpoints return nothing.
    try {
      List<AccountModel> fetchedAccounts = [];
      if (loggedInUserId.isNotEmpty) {
        final List<Account> userAccounts = await _api.getUserAccounts(loggedInUserId);
        fetchedAccounts = userAccounts
            .map((a) => AccountModel(accountNumber: a.accountNumber, balance: a.accountBalance, accountType: a.accountType))
            .toList();
      }

      if (fetchedAccounts.isEmpty) {
        final List<Account> all = await _api.getAllAccounts();
        fetchedAccounts = all
            .map((a) => AccountModel(accountNumber: a.accountNumber, balance: a.accountBalance, accountType: a.accountType))
            .toList();
        debugPrint('fetchAccounts: ApiService returned ${fetchedAccounts.length} accounts');
      }

      setState(() {
        accounts = fetchedAccounts;
      });
    } catch (e) {
      debugPrint('fetchAccounts (ApiService) error: $e');
      setState(() {
        accounts = [];
      });
    }
  }

  Future<void> performWithdrawal(AccountModel account) async {
    final double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount greater than 0")),
      );
      return;
    }
    if (amount > account.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insufficient funds. Available: R${account.balance.toStringAsFixed(2)}")),
      );
      return;
    }

    try {
      // Use ApiService (Dio + interceptor) so Authorization header is included
      final success = await _api.withdrawFromAccountNumber(
        userId: loggedInUserId,
        accountNumber: account.accountNumber,
        amount: amount,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Withdrawal successful")),
        );
        amountController.clear();
        await fetchAccounts(); // refresh balance
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // close dialog if open
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Withdrawal failed")),
        );
      }
    } catch (e) {
      debugPrint('performWithdrawal (ApiService) error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AccountModel? selectedAccount = accounts.isNotEmpty ? accounts[selectedAccountIndex] : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            "Withdraw Cash",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? const Center(child: Text("No accounts found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Card
                      Text("From Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: accounts.length > 1
                              ? () async {
                                  final int? picked = await showModalBottomSheet<int>(
                                    context: context,
                                    builder: (ctx) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...accounts.asMap().entries.map((entry) => ListTile(
                                              title: Text("${entry.value.accountType} - ${entry.value.accountNumber}"),
                                              subtitle: Text("Balance: R${entry.value.balance.toStringAsFixed(2)}"),
                                              onTap: () => Navigator.pop(ctx, entry.key),
                                            ))
                                      ],
                                    ),
                                  );
                                  if (picked != null && picked != selectedAccountIndex) {
                                    setState(() => selectedAccountIndex = picked);
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.blue[700]),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedAccount != null ? selectedAccount.accountType : "-",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        selectedAccount != null ? selectedAccount.accountNumber : "-",
                                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Available", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(
                                      selectedAccount != null ? "R${selectedAccount.balance.toStringAsFixed(2)}" : "-",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                                if (accounts.length > 1)
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.black)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Flexi Amount Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Flexi Amount: R50 – R3,000 (multiples of R50)",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Cellphone Section
                      Text("Receiving Cellphone Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: false,
                        controller: TextEditingController(text: phoneNumber),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      // Amount Input
                      Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "Enter amount",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 40),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: selectedAccount == null
                              ? null
                              : () {
                                  final args = WithdrawalConfirmationArgs(
                                    amount: amountController.text,
                                    accountName: selectedAccount.accountType,
                                    accountNumber: selectedAccount.accountNumber,
                                    cellphoneNumber: phoneNumber,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConfirmationPage(args: args),
                                    ),
                                  );
                                },
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
