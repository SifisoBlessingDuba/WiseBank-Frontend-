import 'dart:convert';

class Transaction {
  final int transactionId; // Java Long can be int
  final String accountNumber; // Store only accountNumber for the Account reference
  // final Account account; // Or parse a minimal Account if provided
  final double amount; // Java BigDecimal, parsed as double
  final String transactionType;
  final DateTime? timestamp; // Java LocalDateTime
  final String? description;
  final String? status;

  Transaction({
    required this.transactionId,
    required this.accountNumber,
    // required this.account,
    required this.amount,
    required this.transactionType,
    this.timestamp,
    this.description,
    this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String parsedAccountNumber;
    if (json['account'] is Map<String, dynamic>) {
      parsedAccountNumber = (json['account'] as Map<String, dynamic>)['accountNumber'] as String;
    } else if (json['account'] is String) {
      // If backend sends only the accountNumber
      parsedAccountNumber = json['account'] as String;
    } else {
      parsedAccountNumber = json['accountNumber'] as String? ?? 'unknown_account'; // fallback
    }

    return Transaction(
      transactionId: json['transactionId'] as int,
      accountNumber: parsedAccountNumber,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) // Assuming ISO string
          : null,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      // Send back minimal account reference or as backend expects for POST/PUT
      'account': {'accountNumber': accountNumber},
      'amount': amount,
      'transactionType': transactionType,
      'timestamp': timestamp?.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
