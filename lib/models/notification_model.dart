class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead; // store as bool in Flutter
  final DateTime timeStamp;
  final String userId; // match your backend userId type

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.timeStamp,
    required this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notificationType'] ?? '',
      // Convert the backend string to bool
      isRead: (json['isRead'] ?? 'false').toString().toLowerCase() == 'true',
      timeStamp: json['timeStamp'] != null
          ? DateTime.parse(json['timeStamp'])
          : DateTime.now(),
      // Parse userId from nested user object
      userId: json['user'] != null && json['user']['userId'] != null
          ? json['user']['userId'].toString()
          : 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'notificationType': notificationType,
      'isRead': isRead.toString(),
      'timeStamp': timeStamp.toIso8601String(),
      'user': {'userId': userId},
    };
  }
}