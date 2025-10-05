import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/globals.dart';
import 'dashboard.dart';
import 'transaction.dart' as transaction_lib;
import 'settings_page.dart';
import '../services/api_service.dart';
import '../models/account.dart';

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
    final url = Uri.parse('$apiBaseUrl/user/read_user/$loggedInUserId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = "${data['firstName']} ${data['lastName']}";
          phoneNumber = data['phoneNumber'] ?? "";
        });
      } else {
        debugPrint("Error fetching user info: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network error: $e");
    }
  }

  Future<void> fetchAccounts() async {
    final List<Uri> candidateUrls = [
      Uri.parse('$apiBaseUrl/account/read_account/by-user/$loggedInUserId'),
      Uri.parse('$apiBaseUrl/account/read_account/$loggedInUserId'),
      Uri.parse('$apiBaseUrl/account/rad_account/$loggedInUserId'),
      Uri.parse('$apiBaseUrl/account/by-user/$loggedInUserId'),
      // Fallback to all accounts if user-specific endpoints fail
      Uri.parse('$apiBaseUrl/account/all_accounts'),
    ];

    bool belongsToCurrentUser(Map<String, dynamic> j) {
      final dynamic owner = j['user'] ?? j['owner'] ?? j['customer'];
      String? id;
      if (j['userId'] != null) id = j['userId'].toString();
      else if (j['userID'] != null) id = j['userID'].toString();
      else if (owner is Map) {
        id = (owner['idNumber'] ?? owner['id'] ?? owner['userId'] ?? owner['userID'])?.toString();
      }
      return id == loggedInUserId || loggedInUserId.isNotEmpty && id == loggedInUserId;
    }

    List<AccountModel> fetchedAccounts = [];
    int? lastStatus;
    String? lastBody;

    for (final url in candidateUrls) {
      try {
        debugPrint('fetchAccounts: Trying URL -> $url');
        final response = await http.get(url);
        lastStatus = response.statusCode;
        lastBody = response.body;
        debugPrint('fetchAccounts: Response ${response.statusCode} from $url');

        if (response.statusCode == 200) {
          if (response.body.isEmpty) {
            debugPrint('fetchAccounts: Empty body from $url');
            continue;
          }
          final dynamic data = jsonDecode(response.body);

          List<AccountModel> parsed = [];
          if (data is List) {
            parsed = data
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .where((j) => belongsToCurrentUser(j) || !url.path.contains('all_accounts'))
                .map<AccountModel>(AccountModel.fromJson)
                .toList();
          } else if (data is Map) {
            final dynamic inner = data['accounts'] ?? data['data'] ?? data['content'] ?? data['items'] ?? data;
            if (inner is List) {
              parsed = inner
                  .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                  .where((j) => belongsToCurrentUser(j) || !url.path.contains('all_accounts'))
                  .map<AccountModel>(AccountModel.fromJson)
                  .toList();
            } else if (inner is Map) {
              final m = Map<String, dynamic>.from(inner);
              if (!url.path.contains('all_accounts') && m.isNotEmpty || belongsToCurrentUser(m)) {
                parsed = [AccountModel.fromJson(m)];
              }
            }
          }

          if (parsed.isNotEmpty) {
            fetchedAccounts = parsed;
            debugPrint('fetchAccounts: Parsed ${fetchedAccounts.length} account(s) from $url');
            break; // success
          } else {
            debugPrint('fetchAccounts: No accounts parsed from $url');
          }
        } else {
          debugPrint('fetchAccounts: Non-200 (${response.statusCode}) from $url, body: ${response.body}');
        }
      } catch (e) {
        debugPrint('fetchAccounts: Error calling $url -> $e');
      }
    }

    // Final fallback: use ApiService.getAllAccounts and map
    if (fetchedAccounts.isEmpty) {
      try {
        debugPrint('fetchAccounts: Falling back to ApiService.getAllAccounts()');
        final List<Account> all = await _api.getAllAccounts();
        fetchedAccounts = all
            .map((a) => AccountModel(accountNumber: a.accountNumber, balance: a.accountBalance, accountType: a.accountType))
            .toList();
        debugPrint('fetchAccounts: ApiService fallback returned ${fetchedAccounts.length} accounts');
      } catch (e) {
        debugPrint('fetchAccounts: ApiService.getAllAccounts failed -> $e');
      }
    }

    setState(() {
      accounts = fetchedAccounts;
    });

    if (fetchedAccounts.isEmpty) {
      debugPrint('fetchAccounts: All attempts failed. Last status: $lastStatus, Last body: $lastBody');
    }
  }

  Future<String?> _fetchAccountIdByNumber(String accountNumber) async {
    final List<Uri> detailUrls = [
      Uri.parse('$apiBaseUrl/account/by-number/$accountNumber'),
      Uri.parse('$apiBaseUrl/account/read_account/number/$accountNumber'),
      Uri.parse('$apiBaseUrl/account/read/$accountNumber'),
      Uri.parse('$apiBaseUrl/account/number/$accountNumber'),
      Uri.parse('$apiBaseUrl/account/find_by_number/$accountNumber'),
    ];

    String? extractId(dynamic json) {
      if (json is Map<String, dynamic>) {
        final keys = json.keys.map((k) => k.toString()).toList();
        debugPrint('resolveAccountId: keys => $keys');
        final candidates = [
          'accountId', 'id', 'accountID', 'account_id', '_id',
          'accountUuid', 'uuid', 'ref', 'reference', 'accountRef', 'accountNoId', 'accountNumberId'
        ];
        for (final key in candidates) {
          final v = json[key];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }
      return null;
    }

    for (final url in detailUrls) {
      try {
        debugPrint('resolveAccountId: Trying $url');
        final res = await http.get(url);
        if (res.statusCode == 200 && res.body.isNotEmpty) {
          final dynamic data = jsonDecode(res.body);
          if (data is List && data.isNotEmpty) {
            final id = extractId(Map<String, dynamic>.from(data.first));
            if (id != null) return id;
          } else if (data is Map) {
            // Try wrapped or direct object
            final Map<String, dynamic> m = Map<String, dynamic>.from(data);
            final directId = extractId(m);
            if (directId != null) return directId;
            final wrappers = ['account', 'data', 'content', 'item'];
            for (final w in wrappers) {
              final inner = m[w];
              if (inner is Map) {
                final id = extractId(Map<String, dynamic>.from(inner));
                if (id != null) return id;
              } else if (inner is List && inner.isNotEmpty) {
                final id = extractId(Map<String, dynamic>.from(inner.first));
                if (id != null) return id;
              }
            }
          }
        } else {
          debugPrint('resolveAccountId: ${res.statusCode} from $url');
        }
      } catch (e) {
        debugPrint('resolveAccountId: Error calling $url -> $e');
      }
    }
    return null;
  }

  Future<void> performWithdrawal(AccountModel account) async {
    final url = Uri.parse('$apiBaseUrl/withdrawals');

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
    if (account.accountId == null || account.accountId!.isEmpty) {
      debugPrint('performWithdrawal: accountId missing, attempting to resolve by accountNumber ${account.accountNumber}');
      final resolvedId = await _fetchAccountIdByNumber(account.accountNumber);
      if (resolvedId != null) {
        setState(() => account.accountId = resolvedId);
        debugPrint('performWithdrawal: Resolved accountId => $resolvedId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account ID not available. Please refresh the page.")),
        );
        return;
      }
    }

    final withdrawalData = {
      "userId": loggedInUserId,
      "accountId": account.accountId, // required by backend (camelCase)
      "account_id": account.accountId, // also provide snake_case for compatibility
      "accountNumber": account.accountNumber,
      "amount": amount,
      "phoneNumber": phoneNumber,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(withdrawalData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Withdrawal successful")),
        );
        amountController.clear();
        await fetchAccounts(); // refresh balance
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // close dialog if open
        }
      } else {
        final body = response.body;
        debugPrint("Withdrawal failed: ${response.statusCode} -> $body");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Withdrawal failed (${response.statusCode}): ${body.isNotEmpty ? body : 'Unknown error'}")),
        );
      }
    } catch (e) {
      debugPrint("Error during withdrawal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Money"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
          ? const Center(child: Text("No accounts found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $userName"),
            Text("Phone: $phoneNumber"),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                        "${account.accountType} - ${account.accountNumber}"),
                    subtitle: Text("Balance: R${account.balance.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.money_off),
                      onPressed: () {
                        _showWithdrawPopup(account);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          _navigateFromBottomNav(index, context);
        },
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
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

  void _showWithdrawPopup(AccountModel account) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Withdraw from ${account.accountType}"),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: "Enter amount"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // Let performWithdrawal close the dialog on success
              performWithdrawal(account);
            },
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );
  }
}
