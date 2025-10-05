import 'transaction.dart';
import 'package:wisebank_frontend/services/globals.dart' as globals;



class Account {
  final String accountNumber;
  double accountBalance;
  final String accountType;
  final double currency;
  final String bankName;
  final String status;
  final String userId;
  final List<Transaction> transactions;


  Account({
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
    }
    if (value is Map) {
      final inner = value['amount'] ?? value['value'] ?? value['balance'];
      return _parseDouble(inner);
    }
    return 0.0;
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
    for (final k in keys) {
      final v = json[k];
      if (v != null) return v.toString();
    }
    return fallback;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    final accountNumber = _pickString(json, ['accountNumber', 'number', 'accountNo'], fallback: '');
    final accountType = _pickString(json, ['accountType', 'type'], fallback: 'Unknown');

    dynamic balanceRaw = json['accountBalance'] ?? json['balance'] ?? json['availableBalance'];
    if (balanceRaw is Map) {
      balanceRaw = balanceRaw['amount'] ?? balanceRaw['value'] ?? balanceRaw['balance'];
    }

    final double balance = _parseDouble(balanceRaw);
    final double currency = _parseDouble(json['currency']);

    final bankName = _pickString(json, ['bankName', 'bank'], fallback: 'N/A');
    final status = _pickString(json, ['status'], fallback: 'Unknown');

    final txList = (json['transactions'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map((x) => Transaction.fromJson(x))
        .toList() ?? const [];

    return Account(
      accountNumber: accountNumber,
      accountBalance: balance,
      accountType: accountType,
      currency: currency,
      bankName: bankName,
      status: status,
      userId: globals.loggedInUserId,
      transactions: txList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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


}