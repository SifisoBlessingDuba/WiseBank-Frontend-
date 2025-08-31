import 'dart:convert';

class Notification {
  final int notificationId;
  final String? title;
  final String? message;
  final String? notificationType;
  final String? isRead; // Kept as String from Java model
  final DateTime? timeStamp; // Java LocalDateTime
  final String userId; // Assuming backend sends userId for the user field

  Notification({
    required this.notificationId,
    this.title,
    this.message,
    this.notificationType,
    this.isRead,
    this.timeStamp,
    required this.userId,
  });

  // Helper to convert isRead string to boolean
  bool get isReadBool => isRead?.toLowerCase() == 'true';

  factory Notification.fromJson(Map<String, dynamic> json) {
    String parsedUserId;
    if (json['user'] is Map<String, dynamic>) {
      parsedUserId = (json['user'] as Map<String, dynamic>)['userId'] as String;
    } else if (json['user'] is String) {
      parsedUserId = json['user'] as String;
    } else {
      parsedUserId = json['userId'] as String? ?? 'unknown_user'; // Fallback
    }

    return Notification(
      notificationId: json['notificationId'] as int,
      title: json['title'] as String?,
      message: json['message'] as String?,
      notificationType: json['notificationType'] as String?,
      isRead: json['isRead'] as String?,
      timeStamp: json['timeStamp'] != null
          ? DateTime.tryParse(json['timeStamp'] as String) // Assuming ISO string
          : null,
      userId: parsedUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'notificationType': notificationType,
      'isRead': isRead,
      'timeStamp': timeStamp?.toIso8601String(),
      'user': {'userId': userId}, // Send back minimal user reference
    };
  }
}
