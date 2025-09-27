import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageService {
  final String baseUrl = "http://10.0.2.2:8080/message";

  /// Get all messages
  Future<List<Message>> getAllMessages() async {
    final uri = Uri.parse("$baseUrl/all");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList.map((item) => Message.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Failed to load messages (code ${response.statusCode})");
    }
  }


}
