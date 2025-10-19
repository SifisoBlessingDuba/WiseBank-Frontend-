import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'globals.dart';

class NotificationService {

  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/find-all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}