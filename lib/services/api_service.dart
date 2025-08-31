import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Import for ChangeNotifier if used later
import '../models/account.dart'; // Adjust path as necessary

class ApiService {
  final String _baseUrl = "http://localhost:8080"; // Your Spring Boot backend URL

  // Fetches all accounts
  Future<List<Account>> getAllAccounts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/account/all_accounts'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        // Add any other headers like Authorization if needed in the future
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      // The response body is expected to be a JSON list of accounts.
      List<dynamic> body = jsonDecode(response.body);
      // In ApiService.dart -> getAllAccounts()
      if (response.statusCode == 200) {
        print('Received JSON for accounts: ${response
            .body}'); // <-- THIS IS CRUCIAL
        final List<dynamic> jsonData = jsonDecode(response.body) as List<
            dynamic>;
        // ... rest of the code
      }
      List<Account> accounts = body
          .map((dynamic item) => Account.fromJson(item as Map<String, dynamic>))
          .toList();
      return accounts;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to load accounts. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load accounts (Status Code: ${response.statusCode})');
    }
  }

// Example of a POST request for creating a transaction (Send Money)
// We will develop this further when we focus on the actual send money functionality
/*
  Future<Transaction> createTransaction(Transaction transactionData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transaction/save'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(transactionData.toJson()), // Assuming your Transaction model has toJson()
    );

    if (response.statusCode == 200 || response.statusCode == 201) { // 201 Created is also common
      return Transaction.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      print('Failed to create transaction. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to create transaction (Status Code: ${response.statusCode})');
    }
  }
  */

// Add other API methods here as needed (e.g., getBeneficiaries, getUserDetails, etc.)
}

// Optional: If you plan to use this ApiService with Provider for state management
// class ApiServiceProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
//   List<Account> _accounts = [];
//   bool _isLoading = false;

//   List<Account> get accounts => _accounts;
//   bool get isLoading => _isLoading;

//   Future<void> fetchAllAccounts() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _accounts = await _apiService.getAllAccounts();
//     } catch (e) {
//       // Handle error appropriately in UI
//       print(e.toString());
//       _accounts = []; // Clear or set to an error state
//     }
//     _isLoading = false;
//     notifyListeners();
//   }
// }
