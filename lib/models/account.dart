import 'dart:convert';
import 'user.dart'; // For User reference
import 'transaction.dart';
import 'package:wisebank_frontend/services/globals.dart' as globals; // ✅ fixed import with alias

// TODO: Import other models as needed: card.dart, loan.dart

class Account {
  final String accountNumber;
  double accountBalance;
  final String accountType;
  final double currency; // Assuming this is a code or simple value, not a full object
  final String bankName;
  final String status;
  final String userId; // Store from global after login
  final List<Transaction> transactions;
  // final List<Loan> loans;
  // final Card card;

  Account({
    required this.accountNumber,
    required this.accountBalance,
    required this.accountType,
    required this.currency,
    required this.bankName,
    required this.status,
    required this.userId,
    this.transactions = const [],
    // this.loans = const [],
    // this.card,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['accountNumber'] as String,
      accountBalance: (json['accountBalance'] as num).toDouble(),
      accountType: json['accountType'] as String,
      currency: (json['currency'] as num).toDouble(),
      bankName: json['bankName'] as String,
      status: json['status'] as String,
      userId: globals.loggedInUserId, // ✅ always use global userId
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((x) => Transaction.fromJson(x as Map<String, dynamic>))
          .toList() ??
          const [],
      // TODO: Deserialize loans, card
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
      // ✅ backend expects "idNumber" for user, not "userId"
      'user': {'idNumber': userId},
      'transactions': transactions.map((x) => x.toJson()).toList(),
      // TODO: Serialize loans, card
    };
  }
}
