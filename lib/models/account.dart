import 'transaction.dart';
import 'package:wisebank_frontend/services/globals.dart' as globals;

class Account {
  final String accountId; // NEW: Required for backend updates
  final String accountNumber;
  double accountBalance;
  final String accountType;
  final double currency;
  final String bankName;
  final String status;
  final String userId;
  final List<Transaction> transactions;

  Account({
    required this.accountId, // NEW
    required this.accountNumber,
    required this.accountBalance,
    required this.accountType,
    required this.currency,
    required this.bankName,
    required this.status,
    required this.userId,
    this.transactions = const [],
  });

  String get accountNumberDisplay {
    if (accountNumber.length > 4) {
      return "**** ${accountNumber.substring(accountNumber.length - 4)}";
    }
    return accountNumber;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final match = RegExp(r'-?[0-9]+(?:[.,][0-9]+)?').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(0)!.replaceAll(',', '')) ?? 0.0;
      }
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    if (value is Map) {
      final inner = value['amount'] ?? value['value'] ?? value['balance'];
      return _parseDouble(inner);
    }
    return 0.0;
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
    for (final k in keys) {
      final dynamic v = json[k];
      if (v != null) return v.toString();
      // also try snake_case variants if user provided camelCase keys
      final snake = k.replaceAllMapped(RegExp(r'([A-Z])'), (m) => '_${m[0]!.toLowerCase()}');
      if (json.containsKey(snake) && json[snake] != null) return json[snake].toString();
    }
    return fallback;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    // Try many possible keys for the id
    final accountId = _pickString(json, ['accountId', 'id', 'account_id', '_id', 'uid'], fallback: '');

    // Try many possible keys for the account number
    final accountNumberRaw = _pickString(json, [
      'accountNumber',
      'account_number',
      'number',
      'accountNo',
      'acctNo',
      'acct_number',
      'acc_number'
    ], fallback: '');

    // If accountNumber is empty, fall back to accountId (so we always have an identifier)
    final accountNumber = accountNumberRaw.isNotEmpty ? accountNumberRaw : (accountId.isNotEmpty ? accountId : '');

    // Balance: support multiple shapes
    dynamic balanceRaw = json['accountBalance'] ?? json['balance'] ?? json['availableBalance'] ?? json['amount'];
    if (balanceRaw is Map) {
      balanceRaw = balanceRaw['amount'] ?? balanceRaw['value'] ?? balanceRaw['balance'];
    }
    final double balance = _parseDouble(balanceRaw);

    final double currency = _parseDouble(json['currency'] ?? json['currencyCode'] ?? json['currency_id']);
    final bankName = _pickString(json, ['bankName', 'bank', 'bank_name'], fallback: 'N/A');
    final status = _pickString(json, ['status', 'state'], fallback: 'Unknown');

    final txList = (json['transactions'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map((x) => Transaction.fromJson(x))
        .toList() ??
        const [];

    // Debugging help: if both id and number are missing, print the JSON so you can inspect it
    if (accountNumber.isEmpty && accountId.isEmpty) {
      print("DEBUG Account.fromJson: missing id/number keys in JSON -> $json");
    } else {
      // helpful debug to confirm mapping during development
      print("DEBUG Account.fromJson: mapped accountId='$accountId', accountNumber='$accountNumber', balance=$balance");
    }

    return Account(
      accountId: accountId,
      accountNumber: accountNumber,
      accountBalance: balance,
      accountType: _pickString(json, ['accountType', 'type'], fallback: 'Unknown'),
      currency: currency,
      bankName: bankName,
      status: status,
      userId: globals.loggedInUserId,
      transactions: txList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountNumber': accountNumber,
      'accountBalance': accountBalance,
      'accountType': accountType,
      'currency': currency,
      'bankName': bankName,
      'status': status,
      'user': {'idNumber': userId},
      'transactions': transactions.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Account(accountId: $accountId, accountNumber: $accountNumber, balance: $accountBalance, type: $accountType)';
  }
}
