import 'dart:convert';

class Notification {
  final int notificationId;
  final String? title;
  final String? message;
  final String? notificationType;
  final String? isRead;
  final DateTime? timeStamp;
  final String userId;

  Notification({
    required this.notificationId,
    this.title,
    this.message,
    this.notificationType,
    this.isRead,
    this.timeStamp,
    required this.userId,
  });


  bool get isReadBool => isRead?.toLowerCase() == 'true';

  factory Notification.fromJson(Map<String, dynamic> json) {
    String parsedUserId;
    if (json['user'] is Map<String, dynamic>) {
      parsedUserId = (json['user'] as Map<String, dynamic>)['userId'] as String;
    } else if (json['user'] is String) {
      parsedUserId = json['user'] as String;
    } else {
      parsedUserId = json['userId'] as String? ?? 'unknown_user';
    }

    return Notification(
      notificationId: json['notificationId'] as int,
      title: json['title'] as String?,
      message: json['message'] as String?,
      notificationType: json['notificationType'] as String?,
      isRead: json['isRead'] as String?,
      timeStamp: json['timeStamp'] != null
          ? DateTime.tryParse(json['timeStamp'] as String)
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
      'user': {'userId': userId},
    };
  }
}
