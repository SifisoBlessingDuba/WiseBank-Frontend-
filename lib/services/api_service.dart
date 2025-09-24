import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/account.dart';
import 'globals.dart';

class ApiService {
  final String _baseUrl = "http://10.0.2.2:8080";

  Future<List<Account>> getAllAccounts() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/account/all_accounts'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',

      },
    );

    if (response.statusCode == 200) {

      List<dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Received JSON for accounts: ${response
            .body}');
        final List<dynamic> jsonData = jsonDecode(response.body) as List<
            dynamic>;

      }
      List<Account> accounts = body
          .map((dynamic item) => Account.fromJson(item as Map<String, dynamic>))
          .toList();
      return accounts;
    } else {

      print('Failed to load accounts. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load accounts (Status Code: ${response.statusCode})');
    }
  }




}

