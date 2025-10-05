import 'account.dart';
import 'user.dart';
import 'withdrawal_status.dart';

class Withdrawal {
  final int withdrawalId;
  final User user;
  final double amount;
  final DateTime withdrawalDate;
  final WithdrawalStatus withdrawalStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Withdrawal({
    required this.withdrawalId,
    required this.user,
    required this.amount,
    required this.withdrawalDate,
    required this.withdrawalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  })
      : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();


  Withdrawal copyWith({
    int? withdrawalId,
    User? user,
    double? amount,
    DateTime? withdrawalDate,
    WithdrawalStatus? withdrawalStatus,
    DateTime? updatedAt,
  }) {
    return Withdrawal(
      withdrawalId: withdrawalId ?? this.withdrawalId,
      user: user ?? this.user,
      amount: amount ?? this.amount,
      withdrawalDate: withdrawalDate ?? this.withdrawalDate,
      withdrawalStatus: withdrawalStatus ?? this.withdrawalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'withdrawalId': withdrawalId,
      'user': user.toJson(),
      'amount': amount,
      'withdrawalDate': withdrawalDate.toIso8601String(),
      'withdrawalStatus': withdrawalStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      withdrawalId: json['withdrawalId'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      // Assumes Account.fromJson
      amount: (json['amount'] as num).toDouble(),
      withdrawalDate: DateTime.parse(json['withdrawalDate'] as String),
      withdrawalStatus: WithdrawalStatus.values.firstWhere(
            (e) => e.name == json['withdrawalStatus'],
        orElse: () => WithdrawalStatus.failed, // Default or error handling
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }


  @override
  String toString() {
    return 'Withdrawal(withdrawalId: $withdrawalId, userId: ${user
        .userId}, amount: $amount, status: $withdrawalStatus, date: $withdrawalDate)';
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Withdrawal &&
        other.withdrawalId == withdrawalId &&
        other.user == user &&
        other.amount == amount &&
        other.withdrawalDate == withdrawalDate &&
        other.withdrawalStatus == withdrawalStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return withdrawalId.hashCode ^
    user.hashCode ^
    amount.hashCode ^
    withdrawalDate.hashCode ^
    withdrawalStatus.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode;
  }
}

