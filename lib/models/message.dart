class Message {
  final int messageId;
  final String content;
  final String status;
  final String? timestamp;

  Message({
    required this.messageId,
    required this.content,
    required this.status,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    messageId: json['messageId'],
    content: json['content'],
    status: json['status'],
    timestamp: json['timestamp'],
  );

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'content': content,
    'status': status,
    'timestamp': timestamp,
  };
}
