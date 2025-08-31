import 'dart:convert';

class Beneficiary {
  final String accountNumber;
  final String name;
  final String bankName;
  final DateTime? addedAt; // Java LocalDate
  final String userId; // Assuming backend sends userId for the user field

  Beneficiary({
    required this.accountNumber,
    required this.name,
    required this.bankName,
    this.addedAt,
    required this.userId,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    String parsedUserId;
    if (json['user'] is Map<String, dynamic>) {
      parsedUserId = (json['user'] as Map<String, dynamic>)['userId'] as String;
    } else if (json['user'] is String) {
      parsedUserId = json['user'] as String;
    } else {
      parsedUserId = json['userId'] as String? ?? 'unknown_user'; // Fallback
    }

    return Beneficiary(
      accountNumber: json['accountNumber'] as String,
      name: json['name'] as String,
      bankName: json['bankName'] as String,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'] as String) // Assuming YYYY-MM-DD
          : null,
      userId: parsedUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'name': name,
      'bankName': bankName,
      'addedAt': addedAt?.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'user': {'userId': userId}, // Send back minimal user reference
    };
  }
}
