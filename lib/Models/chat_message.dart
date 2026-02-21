class ChatMessage {
  final String id;
  final String conversationId;
  final String from;
  final String to;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.from,
    required this.to,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json["_id"] ?? "").toString(),
      conversationId: (json["conversationId"] ?? "").toString(),
      from: (json["from"] ?? "").toString(),
      to: (json["to"] ?? "").toString(),
      text: (json["text"] ?? "").toString(),
      createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}
