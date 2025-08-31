import 'dart:convert';
import 'account.dart';
import 'beneficiary.dart';
// TODO: Import other models as needed: message.dart, notification.dart, card.dart, loan.dart

class User {
  final int userId;
  final String email;
  // password is typically not sent to/from client after login
  final int idNumber;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final int? phoneNumber; // Java Long can be int in Dart if it fits, otherwise String
  final String? address;
  final DateTime? createdAt; // Java LocalDate
  final String? lastLogin;

  final List<Account> accounts;
  final List<Beneficiary> beneficiaries;
  // final List<Message> messages;
  // final List<Notification> notifications;
  // final List<Card> cards;
  // final List<Loan> loans;

  User({
    required this.userId,
    required this.email,
    required this.idNumber,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.createdAt,
    this.lastLogin,
    this.accounts = const [],
    this.beneficiaries = const [],
    // this.messages = const [],
    // this.notifications = const [],
    // this.cards = const [],
    // this.loans = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: (json['userId'] as num).toInt(),
      email: json['email'] as String,
      idNumber: json['idNumber'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String) // Assuming ISO string
          : null,
      phoneNumber: json['phoneNumber'] as int?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) // Assuming YYYY-MM-DD string
          : null,
      lastLogin: json['lastLogin'] as String?,
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((x) => Account.fromJson(x as Map<String, dynamic>))
          .toList() ??
          const [],
      beneficiaries: (json['beneficiaries'] as List<dynamic>?)
          ?.map((x) => Beneficiary.fromJson(x as Map<String, dynamic>))
          .toList() ??
          const [],
      // TODO: Deserialize other lists
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'idNumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt?.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'lastLogin': lastLogin,
      'accounts': accounts.map((x) => x.toJson()).toList(),
      'beneficiaries': beneficiaries.map((x) => x.toJson()).toList(),
      // TODO: Serialize other lists
    };
  }
}
