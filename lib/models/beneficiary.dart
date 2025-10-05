import 'dart:convert';

class Beneficiary {
  final String? id;
  final String accountNumber;
  final String name;
  final String bankName;
  final DateTime? addedAt;
  final String userId;

  Beneficiary({
    this.id,
    required this.accountNumber,
    required this.name,
    required this.bankName,
    this.addedAt,
    required this.userId,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    String parsedUserId;
    if (json['user'] is Map<String, dynamic>) {
      final u = (json['user'] as Map<String, dynamic>);
      parsedUserId = (u['userId'] ?? u['idNumber'] ?? u['id'] ?? 'unknown_user').toString();
    } else if (json['user'] is String) {
      parsedUserId = json['user'] as String;
    } else {
      parsedUserId = json['userId'] as String? ?? 'unknown_user';
    }

    final dynamic rawId = json['id'] ?? json['beneficiaryId'] ?? json['_id'];

    return Beneficiary(
      id: rawId?.toString(),
      accountNumber: (json['accountNumber'] ?? json['account_no'] ?? json['number']).toString(),
      name: (json['name'] ?? json['fullName'] ?? json['beneficiaryName']).toString(),
      bankName: (json['bankName'] ?? json['bank']).toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString())
          : null,
      userId: parsedUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accountNumber': accountNumber,
      'name': name,
      'bankName': bankName,
      'addedAt': addedAt?.toIso8601String().substring(0, 10),
      'user': {'userId': userId},
    };
  }
}
