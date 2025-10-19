import 'dart:convert';
import '../models/account.dart';
import '../models/withdrawal.dart';
import '../models/beneficiary.dart';
import 'package:wisebank_frontend/services/endpoints.dart';
import 'package:wisebank_frontend/services/auth_service.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to host machine's localhost
  final String _baseUrl = "http://localhost:8081";

  Future<List<Account>> getAllAccounts() async {
    // Consider renaming to getAllSystemAccounts
    final String url = '$_baseUrl/account/all_accounts';
    print("ApiService: Fetching all accounts from $url");

    try {
      final dio = AuthService.instance.dio;
      final response = await dio.get(url);
      final status = response.statusCode ?? 0;
      final respBody = response.data;

      if (status == 200) {
        if (respBody == null || (respBody is String && respBody.isEmpty)) {
          print('ApiService (getAllAccounts): Response body is empty. Returning empty list.');
          return [];
        }
        final body = respBody is String ? jsonDecode(respBody) : respBody;
        print('ApiService: Received JSON for all accounts: ${body}');
        // Safely convert the decoded JSON to List<Account>
        if (body is List) {
          final List<Account> accounts = body
              .whereType<Map<String, dynamic>>()
              .map((item) => Account.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return accounts;
        } else {
          print('ApiService (getAllAccounts): Unexpected JSON shape for all accounts, expected List but got ${body.runtimeType}');
          return <Account>[];
        }
      } else {
        final bodyString = response.data is String ? response.data : jsonEncode(response.data);
        print('ApiService: Failed to load all accounts. Status code: ${status}');
        print('ApiService: Response body: ${bodyString}');
        throw Exception('Failed to load all accounts (Status Code: ${status})');
      }
    } catch (e) {
      print('ApiService: Exception in getAllAccounts: $e');
      rethrow;
    }
  }

  /// Fetch accounts for the authenticated user using the /account/me endpoint.
  /// Preferred to avoid passing a userId (email vs id mismatch issues).
  Future<List<Account>> getMyAccounts() async {
    try {
      final dio = AuthService.instance.dio;
      final response = await dio.get(Endpoints.accountMe);
      final status = response.statusCode ?? 0;
      final body = response.data;

      if (status == 200) {
        final dynamic data = body is String ? jsonDecode(body) : body;
        if (data is List) {
          return data.map<Account>((json) => Account.fromJson(Map<String, dynamic>.from(json))).toList();
        } else if (data is Map) {
          final inner = data['accounts'] ?? data['data'] ?? data['content'] ?? data;
          if (inner is List) {
            return inner.map<Account>((json) => Account.fromJson(Map<String, dynamic>.from(json))).toList();
          } else if (inner is Map) {
            return [Account.fromJson(Map<String, dynamic>.from(inner))];
          }
        }
        return const <Account>[];
      } else if (status == 204) {
        return const <Account>[];
      } else {
        print('ApiService.getMyAccounts: Non-200 ($status) body: ${response.data}');
        return const <Account>[];
      }
    } catch (e) {
      print('ApiService.getMyAccounts: Error -> $e');
      return const <Account>[];
    }
  }

  /// Public wrapper to fetch user details by idNumber (uses Dio + interceptor)
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final result = await _fetchUserDetails(userId);
      return result;
    } catch (e) {
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
        // Use Dio with interceptor to ensure Authorization header is applied consistently.
        final dio = AuthService.instance.dio;
        final response = await dio.get(uri.toString());
        lastStatus = response.statusCode;
        // Dio may return decoded JSON in response.data; convert to string for logging if needed
        lastBody = response.data is String ? response.data : jsonEncode(response.data);

        // When using Dio, normalize status code retrieval
        final status = response.statusCode ?? (response.statusMessage != null ? 0 : 0);

        if (status != 200) {
          print('ApiService.getUserAccounts: Non-200 ($status) from $uri, body: $lastBody');
          continue;
        }

        // Guard against null lastBody before checking emptiness
        if (lastBody == null || lastBody.isEmpty) {
          print('ApiService.getUserAccounts: Empty body from $uri');
          continue;
        }

        final dynamic data = response.data is String ? jsonDecode(response.data) : response.data;
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
      final dio = AuthService.instance.dio;
      final response = await dio.get(url);
      final status = response.statusCode ?? 0;
      final bodyContent = response.data;

      if (status == 200) {
        if (bodyContent == null || (bodyContent is String && bodyContent.isEmpty)) {
          print('ApiService (_fetchUserDetails): Response body is empty.');
          throw Exception('User details response body is empty (Path: $url).');
        }
        if (bodyContent is Map<String, dynamic>) {
          return bodyContent;
        }
        if (bodyContent is String) {
          return jsonDecode(bodyContent) as Map<String, dynamic>;
        }
        // fallback: try to convert to Map
        return Map<String, dynamic>.from(bodyContent);
      } else {
        final bodyString = bodyContent is String ? bodyContent : jsonEncode(bodyContent);
        print('ApiService: Failed to load user. Status: $status, Body: $bodyString');
        throw Exception('Failed to load user (Status Code: $status, Path: $url)');
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
      final dio = AuthService.instance.dio;
      final response = await dio.post(withdrawalUrl, data: {
        'userId': loggedInUserId,
        'phoneNumber': phoneNumber,
        'accountNumber': accountNumber,
        'amount': amount,
      });

      final status = response.statusCode ?? 0;
      final respData = response.data;
      if (status == 200 || status == 201) {
        if (respData == null || (respData is String && respData.isEmpty)) {
          print('ApiService (withdrawFromAccount): Withdrawal successful but response body is empty.');
          throw Exception('Withdrawal successful but no data returned from server.');
        }
        final responseData = respData is String ? jsonDecode(respData) : respData;
        print('ApiService: Withdrawal successful. Response Data: $responseData');
        return Withdrawal.fromJson(responseData);
      } else {
        final bodyString = response.data is String ? response.data : jsonEncode(response.data);
        print('ApiService: Failed withdrawal. Status: ${status}, Body: ${bodyString}');
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

      final dio = AuthService.instance.dio;
      final res = await dio.post(withdrawalUrl, data: {
        'userId': userId,
        'phoneNumber': phoneNumber ?? '',
        'accountNumber': accountNumber,
        'amount': amount,
      });
      final status = res.statusCode ?? 0;
      return status == 200 || status == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<Beneficiary>> getUserBeneficiaries(String userId) async {
    try {
      final dio = AuthService.instance.dio;
      final res = await dio.get(Endpoints.beneficiaryAll);
      final status = res.statusCode ?? 0;
      final bodyData = res.data;
      if (status == 200 && bodyData != null) {
        final dynamic data = bodyData is String ? jsonDecode(bodyData) : bodyData;
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
    final List<String> candidates = [
      '$_baseUrl/beneficiaries/by-user/$userId',
      '$_baseUrl/beneficiary/by-user/$userId',
      '$_baseUrl/beneficiaries/user/$userId',
      '$_baseUrl/beneficiary/user/$userId',
      '$_baseUrl/beneficiary/read/$userId',
    ];

    final dio = AuthService.instance.dio;
    for (final uri in candidates) {
      try {
        final res = await dio.get(uri);
        final status = res.statusCode ?? 0;
        final bodyData = res.data;
        if (status != 200 || bodyData == null) continue;
        final dynamic data = bodyData is String ? jsonDecode(bodyData) : bodyData;
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
      final dio = AuthService.instance.dio;
      final res = await dio.post(Endpoints.beneficiarySave, data: payload);
      final status = res.statusCode ?? 0;
      final bodyData = res.data;
      if (status == 200 || status == 201) {
        if (bodyData == null || (bodyData is String && bodyData.isEmpty)) {
          return Beneficiary(
            accountNumber: accountNumber,
            name: name,
            bankName: bankName,
            addedAt: DateTime.now(),
            userId: userId,
          );
        }
        final dynamic data = bodyData is String ? jsonDecode(bodyData) : bodyData;
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
        final status = res.statusCode ?? 0;
        final bodyString = res.data is String ? res.data : jsonEncode(res.data);
        if (status == 409 || bodyString.toLowerCase().contains('exist') || bodyString.toLowerCase().contains('duplicate')) {
          throw Exception('A beneficiary with this account number already exists.');
        }
        throw Exception('Failed to add beneficiary ($status): ${bodyString.isNotEmpty ? bodyString : 'No details'}');
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
    final res = await AuthService.instance.dio.put(Endpoints.beneficiaryUpdate, data: payload);
    final status = res.statusCode ?? 0;
    final bodyData = res.data;
    if (status == 200) {
      final dynamic data = bodyData is String ? jsonDecode(bodyData) : bodyData;
      if (data is Map<String, dynamic>) {
        final inner = data['beneficiary'] ?? data['data'] ?? data;
        if (inner is Map<String, dynamic>) return Beneficiary.fromJson(inner);
        return Beneficiary.fromJson(data);
      }
      return null;
    }
    final status2 = res.statusCode ?? 0;
    final bodyStr2 = res.data is String ? res.data : jsonEncode(res.data);
    if (status2 == 409 || bodyStr2.toLowerCase().contains('exist') || bodyStr2.toLowerCase().contains('duplicate')) {
      throw Exception('A beneficiary with this account number already exists.');
    }
    throw Exception('Failed to update beneficiary ($status2): ${bodyStr2.isNotEmpty ? bodyStr2 : 'No details'}');
  }

  Future<bool> deleteBeneficiary(String id) async {
    final res = await AuthService.instance.dio.delete(Endpoints.beneficiaryDelete(id));
    final status = res.statusCode ?? 0;
    return status == 200 || status == 204;
  }
}