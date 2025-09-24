

class Transaction {
  final int transactionId;
  final String accountNumber;

  final double amount;
  final String transactionType;
  final DateTime? timestamp;
  final String? description;
  final String? status;

  Transaction({
    required this.transactionId,
    required this.accountNumber,

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

      parsedAccountNumber = json['account'] as String;
    } else {
      parsedAccountNumber = json['accountNumber'] as String? ?? 'unknown_account';
    }

    return Transaction(
      transactionId: json['transactionId'] as int,
      accountNumber: parsedAccountNumber,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,

      'account': {'accountNumber': accountNumber},
      'amount': amount,
      'transactionType': transactionType,
      'timestamp': timestamp?.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
