class Message {
  final int messageId;
  final String content;
  final String? timestamp;
  final String status;

  Message({
    required this.messageId,
    required this.content,
    this.timestamp,
    required this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    messageId: json['messageId'],
    content: json['content'],
    timestamp: json['timestamp'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'content': content,
    'timestamp': timestamp,
    'status': status,
  };
}
