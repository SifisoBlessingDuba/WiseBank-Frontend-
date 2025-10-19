import 'package:flutter/material.dart';
import 'package:wisebank_frontend/services/auth_service.dart';
import 'package:wisebank_frontend/services/endpoints.dart';
import 'Pages/login_page.dart'; // Your login screen
import 'Pages/dashboard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize auth service (sets up Dio interceptor)
  await AuthService.instance.init();

  // Debug: print whether token exists (masked)
  final token = await authGetToken();
  if (token != null && token.isNotEmpty) {
    final masked = token.length > 12 ? token.substring(0, 8) + '...' + token.substring(token.length - 4) : token;
    print('DEBUG: Auth token present (masked): $masked');
  } else {
    print('DEBUG: No auth token present at startup');
  }

  // DIAGNOSTIC: perform a GET using the Dio instance and print headers/response
  // This will show whether the Authorization header is actually sent and how the server responds.
  try {
    final diagnosticPath = '${Endpoints.baseUrl}/account/read_account/by-user/0312046096086';
    await AuthService.instance.diagnosticGet(diagnosticPath);
  } catch (e) {
    print('DIAG_CALL_ERROR: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listener to react to auth state changes (logout on 401 will set false)
    _authListener = () {
      final loggedIn = AuthService.instance.authState.value;
      if (!loggedIn) {
        // navigate to login and clear stack
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        // if logged in, navigate to dashboard
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Dashboard()),
          (route) => false,
        );
      }
    };

    AuthService.instance.authState.addListener(_authListener);
  }

  @override
  void dispose() {
    AuthService.instance.authState.removeListener(_authListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // When app goes to background or is detached, optionally clear token locally
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final autoClear = await AuthService.instance.getAutoClearOnBackground();
      if (autoClear) {
        // local clear only, do not attempt remote network during lifecycle event
        await AuthService.instance.logout(remote: false);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'WiseBank',
      home: const LoginPage(),
    );
  }
}
