import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import '../models/withdrawal.dart';
import '../models/beneficiary.dart';
import 'package:wisebank_frontend/services/endpoints.dart';
import 'globals.dart';

class ApiService {

  final String _baseUrl = apiBaseUrl;

  Future<bool> withdrawAmount({
    required String accountId,
    required double newBalance,
  }) async {
    final url = Uri.parse("$_baseUrl/account/update");
    final body = {
      "accountId": accountId,
      "accountBalance": newBalance,
    };
    print("Sending PUT request: $body");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("Response status: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to update account balance: ${response.statusCode}");
    }
  }

  Future<void> createTransaction(Map<String, dynamic> transactionData) async {
    final url = Uri.parse('$apiBaseUrl/transaction/save');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(transactionData),
    );
    print(response.statusCode);
    print(transactionData);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create transaction');
    }
  }

  Future<bool> createNotification(Map<String, dynamic> notificationData) async {
    final url = Uri.parse("$_baseUrl/notification/save");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(notificationData),
    );
    print(response.statusCode);
    print(notificationData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Failed to create notification: ${response.statusCode} ${response.body}");
      return false;
    }
  }



  Future<List<Account>> getAllAccounts() async {
    // Consider renaming to getAllSystemAccounts
    final String url = '$_baseUrl/account/all_accounts';
    print("ApiService: Fetching all accounts from $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print(
              'ApiService (getAllAccounts): Response body is empty. Returning empty list.');
          return [];
        }
        print('ApiService: Received JSON for all accounts: ${response.body}');
        List<dynamic> body = jsonDecode(response.body);
        List<Account> accounts = body
            .map((dynamic item) =>
            Account.fromJson(item as Map<String, dynamic>))
            .toList();
        return accounts;
      } else {
        print('ApiService: Failed to load all accounts. Status code: ${response
            .statusCode}');
        print('ApiService: Response body: ${response.body}');
        throw Exception('Failed to load all accounts (Status Code: ${response
            .statusCode})');
      }
    } catch (e) {
      print('ApiService: Exception in getAllAccounts: $e');
      rethrow;
    }
  }

  Future<List<Account>> getUserAccounts(String userId) async {
    final List<Uri> candidateUrls = [
      Uri.parse('$_baseUrl/account/read_account/by-user/$userId'),
      Uri.parse('$_baseUrl/account/read_account/$userId'),
      Uri.parse('$_baseUrl/account/rad_account/$userId'),
      Uri.parse('$_baseUrl/account/by-user/$userId'),
    ];

    List<Account> accounts = [];
    int? lastStatus;
    String? lastBody;

    for (final uri in candidateUrls) {
      try {
        print("ApiService.getUserAccounts: Trying $uri");
        final response = await http.get(uri);
        lastStatus = response.statusCode;
        lastBody = response.body;

        if (response.statusCode != 200) {
          print('ApiService.getUserAccounts: Non-200 (${response.statusCode}) from $uri, body: ${response.body}');
          continue;
        }

        if (response.body.isEmpty) {
          print('ApiService.getUserAccounts: Empty body from $uri');
          continue;
        }

        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          accounts = data
              .map<Account>((json) => Account.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } else if (data is Map) {
          final dynamic inner = data['accounts'] ?? data['data'] ?? data['content'] ?? data;
          if (inner is List) {
            accounts = inner
                .map<Account>((json) => Account.fromJson(Map<String, dynamic>.from(json)))
                .toList();
          } else if (inner is Map) {
            accounts = [Account.fromJson(Map<String, dynamic>.from(inner))];
          } else {
            accounts = [];
          }
        } else {
          accounts = [];
        }

        if (accounts.isNotEmpty) {
          print('ApiService.getUserAccounts: Parsed ${accounts.length} account(s) from $uri');
          break; // success
        } else {
          print('ApiService.getUserAccounts: Parsed 0 accounts from $uri');
        }
      } catch (e) {
        print('ApiService.getUserAccounts: Error calling $uri -> $e');
      }
    }

    if (accounts.isEmpty) {
      print('ApiService.getUserAccounts: All attempts failed. Last status: $lastStatus, Last body: $lastBody');
    }

    return accounts;
  }


  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final String url = '$_baseUrl/user/read_user/$userId';
    print("ApiService: Fetching user details from $url for userId: $userId");
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('ApiService (_fetchUserDetails): Response body is empty.');
          throw Exception('User details response body is empty (Path: $url).');
        }
        Map<String, dynamic> body = jsonDecode(response.body) as Map<
            String,
            dynamic>;
        return body;
      } else {
        print('ApiService: Failed to load user. Status: ${response
            .statusCode}, Body: ${response.body}');
        throw Exception('Failed to load user (Status Code: ${response
            .statusCode}, Path: $url)');
      }
    } catch (e) {
      print("ApiService: Exception in _fetchUserDetails: $e");
      rethrow;
    }
  }

  // MODIFIED to return Future<Withdrawal?> and corrected logic
  Future<Withdrawal?> withdrawFromAccount(String loggedInUserId,
      double amount) async {
    final String withdrawalUrl = '$_baseUrl/withdrawals';
    print(
        "ApiService: Attempting withdrawal. UserID: $loggedInUserId, Amount: $amount, URL: $withdrawalUrl");

    try {
      // 1. Fetch user details to get phone number
      final userResponse = await _fetchUserDetails(loggedInUserId);
      final String? phoneNumber = userResponse['phoneNumber'] as String?;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        print('ApiService: Phone number not found for user $loggedInUserId.');
        throw Exception('Phone number not found for user.');
      }

      // 2. Fetch user's accounts to find the Cheque account number
      final accounts = await getUserAccounts(loggedInUserId);
      Account? chequeAccount;
      try {
        chequeAccount = accounts.firstWhere(
              (acc) => acc.accountType.toLowerCase() == 'cheque',
        );
      } catch (e) {
        print(
            'ApiService: No Cheque account found using firstWhere for user $loggedInUserId.');
        chequeAccount = null;
      }

      if (chequeAccount == null) {
        print(
            'ApiService: No Cheque account available for user $loggedInUserId.');
        throw Exception('No Cheque account found for this user.');
      }
      final String accountNumber = chequeAccount.accountNumber;

      // 3. Perform the withdrawal POST request
      final response = await http.post(
        Uri.parse(withdrawalUrl), // Use _baseUrl and the correct path
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',

        },
        body: jsonEncode(<String, dynamic>{
          'userId': loggedInUserId,
          'phoneNumber': phoneNumber,
          'accountNumber': accountNumber,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (response.body.isEmpty) {
          print(
              'ApiService (withdrawFromAccount): Withdrawal successful but response body is empty.');

          throw Exception(
              'Withdrawal successful but no data returned from server.');
        }
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
            'ApiService: Withdrawal successful. Response Data: $responseData');
        // Assuming the responseData is the JSON for the Withdrawal object
        return Withdrawal.fromJson(responseData);
      } else {
        print('ApiService: Failed withdrawal. Status: ${response
            .statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('ApiService: Error during automated withdrawal: $e');
      return null;
    }
  }

  Future<bool> withdrawFromAccountNumber({
    required String userId,
    required String accountNumber,
    required double amount,
  }) async {
    final String withdrawalUrl = Endpoints.withdrawals;
    try {
      final user = await _fetchUserDetails(userId);
      final String? phoneNumber = user['phoneNumber'] as String?;

      final res = await http.post(
        Uri.parse(withdrawalUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'userId': userId,
          'phoneNumber': phoneNumber ?? '',
          'accountNumber': accountNumber,
          'amount': amount,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<List<Beneficiary>> getUserBeneficiaries(String userId) async {
    try {
      final res = await http.get(Uri.parse(Endpoints.beneficiaryAll));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final dynamic data = jsonDecode(res.body);
        List<Beneficiary> all = [];
        if (data is List) {
          all = data.whereType<Map<String, dynamic>>().map(Beneficiary.fromJson).toList();
        } else if (data is Map<String, dynamic>) {
          final inner = data['beneficiaries'] ?? data['data'] ?? data['content'] ?? data['items'] ?? data;
          if (inner is List) {
            all = inner.whereType<Map<String, dynamic>>().map(Beneficiary.fromJson).toList();
          } else if (inner is Map<String, dynamic>) {
            all = [Beneficiary.fromJson(inner)];
          }
        }
        if (all.isEmpty) return [];
        final bool hasUserLinks = all.any((b) => b.userId != 'unknown_user' && b.userId.isNotEmpty);
        if (!hasUserLinks) {
          // Backend didn't attach user info; return all so UI can still show entries
          return all;
        }
        return all.where((b) => b.userId == userId).toList();
      }
    } catch (e) {
      // fall back below
    }

    // Fallbacks (legacy variants)
    final List<Uri> candidates = [
      Uri.parse('$_baseUrl/beneficiaries/by-user/$userId'),
      Uri.parse('$_baseUrl/beneficiary/by-user/$userId'),
      Uri.parse('$_baseUrl/beneficiaries/user/$userId'),
      Uri.parse('$_baseUrl/beneficiary/user/$userId'),
      Uri.parse('$_baseUrl/beneficiary/read/$userId'),
    ];

    for (final uri in candidates) {
      try {
        final res = await http.get(uri);
        if (res.statusCode != 200 || res.body.isEmpty) continue;
        final dynamic data = jsonDecode(res.body);
        List<Beneficiary> all = [];
        if (data is List) {
          all = data
              .whereType<Map<String, dynamic>>()
              .map((m) => Beneficiary.fromJson(m))
              .toList();
        } else if (data is Map) {
          final inner = data['beneficiaries'] ?? data['data'] ?? data['content'] ?? data['items'] ?? data;
          if (inner is List) {
            all = inner
                .whereType<Map<String, dynamic>>()
                .map((m) => Beneficiary.fromJson(m))
                .toList();
          } else if (inner is Map) {
            all = [Beneficiary.fromJson(Map<String, dynamic>.from(inner))];
          }
        }
        if (all.isEmpty) return [];
        final bool hasUserLinks = all.any((b) => b.userId != 'unknown_user' && b.userId.isNotEmpty);
        if (!hasUserLinks) {
          return all;
        }
        return all.where((b) => b.userId == userId).toList();
      } catch (_) {}
    }
    return [];
  }
  Future<Beneficiary?> createBeneficiary({
    required String userId,
    required String name,
    required String accountNumber,
    required String bankName,
  }) async {
    final payload = <String, dynamic>{
      'accountNumber': accountNumber,
      'name': name,
      'bankName': bankName,
      'user': {'idNumber': userId},
    };

    try {
      final res = await http.post(
        Uri.parse(Endpoints.beneficiarySave),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.body.isEmpty) {
          return Beneficiary(
            accountNumber: accountNumber,
            name: name,
            bankName: bankName,
            addedAt: DateTime.now(),
            userId: userId,
          );
        }
        final dynamic data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) {
          final inner = data['beneficiary'] ?? data['data'] ?? data;
          if (inner is Map<String, dynamic>) {
            return Beneficiary.fromJson(inner);
          }
          return Beneficiary.fromJson(data);
        }
        if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
          return Beneficiary.fromJson(data.first as Map<String, dynamic>);
        }
        return Beneficiary(
          accountNumber: accountNumber,
          name: name,
          bankName: bankName,
          addedAt: DateTime.now(),
          userId: userId,
        );
      } else {
        final body = res.body;
        if (res.statusCode == 409 || body.toLowerCase().contains('exist') || body.toLowerCase().contains('duplicate')) {
          throw Exception('A beneficiary with this account number already exists.');
        }
        throw Exception('Failed to add beneficiary (${res.statusCode}): ${body.isNotEmpty ? body : 'No details'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Beneficiary?> updateBeneficiary({
    required String id,
    String? name,
    String? accountNumber,
    String? bankName,
    String? userId,
  }) async {
    final payload = <String, dynamic>{
      'id': id,
      if (name != null) 'name': name,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (bankName != null) 'bankName': bankName,
      if (userId != null) 'user': {'idNumber': userId},
    };
    final res = await http.put(
      Uri.parse(Endpoints.beneficiaryUpdate),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200) {
      final dynamic data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        final inner = data['beneficiary'] ?? data['data'] ?? data;
        if (inner is Map<String, dynamic>) return Beneficiary.fromJson(inner);
        return Beneficiary.fromJson(data);
      }
      return null;
    }
    if (res.statusCode == 409 || res.body.toLowerCase().contains('exist') || res.body.toLowerCase().contains('duplicate')) {
      throw Exception('A beneficiary with this account number already exists.');
    }
    throw Exception('Failed to update beneficiary (${res.statusCode}): ${res.body.isNotEmpty ? res.body : 'No details'}');
  }

  Future<bool> deleteBeneficiary(String id) async {
    final res = await http.delete(Uri.parse(Endpoints.beneficiaryDelete(id)));
    if (res.statusCode == 200 || res.statusCode == 204) return true;
    return false;
  }
}