import 'dart:convert';
import 'user.dart'; // For User reference
import 'transaction.dart';
// TODO: Import other models as needed: card.dart, loan.dart

class Account {
  final String accountNumber;
  double accountBalance;
  final String accountType;
  final double currency; // Assuming this is a code or simple value, not a full object
  final String bankName;
  final String status;
  final String userId; // Store only userId to avoid circular User object parsing initially
  // final User user; // Or parse a minimal User if provided, or handle full User carefully
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
    // required this.user,
    this.transactions = const [],
    // this.loans = const [],
    // this.card,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    // Critical assumption: json['user'] might be a full User object or just an ID.
    // If it's a full User object, ensure it doesn't cause parsing loops.
    // Here, we assume it might be a Map containing at least 'userId'.
    String parsedUserId;
    if (json['user'] is Map<String, dynamic>) {
      parsedUserId = (json['user'] as Map<String, dynamic>)['userId'] as String;
    } else if (json['user'] is String) {
      // If the backend sends only the userId directly for the user field
      parsedUserId = json['user'] as String;
    } else {
      // Fallback or error if user structure is unexpected or null
      // This might happen if an Account is deserialized outside a User context
      // and the backend provides full User details.
      // For now, let's try to get it from a potential top-level 'userId' if user is complex/absent
      parsedUserId = json['userId'] as String? ?? 'unknown_user'; // Or throw error
    }

    return Account(
      accountNumber: json['accountNumber'] as String,
      accountBalance: (json['accountBalance'] as num).toDouble(),
      accountType: json['accountType'] as String,
      currency: (json['currency'] as num).toDouble(),
      bankName: json['bankName'] as String,
      status: json['status'] as String,
      userId: parsedUserId,
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
      'user': {'userId': userId}, // Send back minimal user reference, or as backend expects
      'transactions': transactions.map((x) => x.toJson()).toList(),
      // TODO: Serialize loans, card
    };
  }
}
