import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../utils/auth_storage.dart';

class MessageService {
  final String baseUrl = "http://10.0.2.2:8080/message";

  Future<List<Message>> getAllMessages() async {
    final uri = Uri.parse("$baseUrl/all");
    final response = await http.get(uri);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load messages");
    }
  }

  Future<List<Message>> getMessagesForUser() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) throw Exception("User not logged in");

    final uri = Uri.parse("$baseUrl/user/$userId");
    final response = await http.get(uri);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load messages for user $userId");
    }
  }
}
