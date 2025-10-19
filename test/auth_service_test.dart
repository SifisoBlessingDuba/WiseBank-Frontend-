import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisebank_frontend/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService preference tests', () {
    test('auto clear preference default is false and can be set', () async {
      SharedPreferences.setMockInitialValues({});
      final svc = AuthService.instance;

      // Ensure default
      final defaultVal = await svc.getAutoClearOnBackground();
      expect(defaultVal, isFalse);

      // Set to true
      await svc.setAutoClearOnBackground(true);
      final newVal = await svc.getAutoClearOnBackground();
      expect(newVal, isTrue);

      // Set back to false
      await svc.setAutoClearOnBackground(false);
      final finalVal = await svc.getAutoClearOnBackground();
      expect(finalVal, isFalse);
    });
  });
}

