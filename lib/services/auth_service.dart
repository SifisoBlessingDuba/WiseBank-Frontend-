import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for storage
const String _tokenKey = 'auth_token';
const String _pendingLogoutKey = 'pending_logout_tokens';
const String _autoClearOnBackgroundKey = 'auth.auto_clear_on_background';

class AuthService {
  // Singleton
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  /// A simple notifier you can listen to from your app to react to auth changes
  /// true = logged in, false = logged out
  final ValueNotifier<bool> authState = ValueNotifier<bool>(false);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));

  Future<void> init() async {
    // Add interceptor to inject Authorization header and handle 401
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          // Clear token on 401
          await logout(remote: false);
          // You may want to broadcast an event or navigate to login externally
        }
        return handler.next(err);
      },
    ));

    // initialize notifier based on existing token
    final t = await getToken();
    try {
      if (t != null && t.isNotEmpty && !JwtDecoder.isExpired(t)) {
        authState.value = true;
      } else {
        authState.value = false;
      }
    } catch (_) {
      authState.value = false;
    }

    // Attempt to flush any pending logout requests (best-effort)
    _flushPendingLogouts();
  }

  Dio get dio {
    return _dio;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    authState.value = true;
    // When a new token is saved, try to flush any pending blacklists (in case network is back)
    _flushPendingLogouts();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Logout helper that attempts remote server-side blacklisting and then
  /// clears the local token. If [remote] is false, only the local token is cleared.
  /// If remote call fails, token will be queued locally for a later retry.
  Future<void> logout({bool remote = true}) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      // Nothing to do; ensure local cleared and notify
      await _storage.delete(key: _tokenKey);
      authState.value = false;
      return;
    }

    if (remote) {
      try {
        final oneOff = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
        oneOff.options.headers['Authorization'] = 'Bearer $token';
        await oneOff.post('/auth/logout');
        // remote success - remove any duplicates from pending queue
        await _removePendingLogout(token);
      } catch (e) {
        // Remote failed: enqueue for later and proceed to local deletion (optimistic)
        await _enqueuePendingLogout(token);
        if (kDebugMode) print('AuthService.logout: remote call failed, queued token for retry -> $e');
      }
    }

    // Always clear local token and notify listeners
    await _storage.delete(key: _tokenKey);
    authState.value = false;
  }

  // Simple login implementation used by top-level helper. Attempts to login
  // on the server and save the returned token. Returns the token on success
  // or null on failure.
  Future<String?> login({required String username, required String password}) async {
    try {
      final res = await _dio.post('/auth/login', data: {'username': username, 'password': password});
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Try to extract token from common response shapes
        String? token;
        if (res.data is Map) {
          token = (res.data as Map).containsKey('token') ? res.data['token'] as String? : null;
          // Some APIs embed the token under 'data' -> 'token'
          if (token == null && (res.data as Map).containsKey('data')) {
            final d = (res.data as Map)['data'];
            if (d is Map && d.containsKey('token')) token = d['token'] as String?;
          }
        } else if (res.data is String) {
          token = res.data as String;
        }

        if (token != null && token.isNotEmpty) {
          await saveToken(token);
          return token;
        }
      }
    } catch (e) {
      if (kDebugMode) print('AuthService.login error: $e');
    }
    return null;
  }

  // Pending logout queue helpers (store list of tokens as JSON array in secure storage)
  Future<List<String>> _readPendingLogouts() async {
    final s = await _storage.read(key: _pendingLogoutKey);
    if (s == null || s.isEmpty) return [];
    try {
      final List<dynamic> j = jsonDecode(s);
      return j.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePendingLogouts(List<String> tokens) async {
    await _storage.write(key: _pendingLogoutKey, value: jsonEncode(tokens));
  }

  Future<void> _enqueuePendingLogout(String token) async {
    final List<String> tokens = await _readPendingLogouts();
    if (!tokens.contains(token)) tokens.add(token);
    await _writePendingLogouts(tokens);
  }

  Future<void> _removePendingLogout(String token) async {
    final List<String> tokens = await _readPendingLogouts();
    tokens.removeWhere((t) => t == token);
    await _writePendingLogouts(tokens);
  }

  /// Attempt to POST any pending logout tokens to the server (best-effort).
  Future<void> _flushPendingLogouts() async {
    final List<String> tokens = await _readPendingLogouts();
    if (tokens.isEmpty) return;
    final Dio oneOff = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
    final List<String> failed = [];
    for (final t in tokens) {
      try {
        oneOff.options.headers['Authorization'] = 'Bearer $t';
        final res = await oneOff.post('/auth/logout');
        if (res.statusCode == 200 || res.statusCode == 204) {
          // success - continue
        } else {
          failed.add(t);
        }
      } catch (_) {
        failed.add(t);
      }
    }
    // Save back only failures
    await _writePendingLogouts(failed);
  }

  /// Diagnostic helper: perform a GET to the provided [url] using the configured
  /// Dio instance and print request/response headers and status for debugging.
  /// This is intentionally lightweight and intended only for development use.
  Future<Response> diagnosticGet(String url) async {
    if (kDebugMode) print('DIAGNOSTIC: GET -> $url');
    final res = await _dio.get(url);
    if (kDebugMode) {
      print('DIAGNOSTIC: status=${res.statusCode}');
      try {
        print('DIAGNOSTIC: response=${res.data}');
      } catch (_) {}
      try {
        print('DIAGNOSTIC: sent headers=${res.requestOptions.headers}');
      } catch (_) {}
    }
    return res;
  }

  // Auto-clear on background preference helpers
  Future<void> setAutoClearOnBackground(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoClearOnBackgroundKey, value);
  }

  Future<bool> getAutoClearOnBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoClearOnBackgroundKey) ?? false;
  }
}

// Top-level convenience wrappers to avoid consumers having to reference the singleton directly.
Future<String?> authLogin({required String username, required String password}) async {
  return await AuthService.instance.login(username: username, password: password);
}

Future<String?> authGetToken() async {
  return await AuthService.instance.getToken();
}

Future<void> authLogout() async {
  return await AuthService.instance.logout();
}
