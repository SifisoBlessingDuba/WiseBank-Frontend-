import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  late final String baseUrl;

  NotificationService() {
    if (kIsWeb) {
      baseUrl = "http://localhost:8080/notification";
    } else if (Platform.isAndroid) {
      baseUrl = "http://10.0.2.2:8080/notification";
    } else {
      baseUrl = "http://localhost:8080/notification";
    }
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/find-all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}