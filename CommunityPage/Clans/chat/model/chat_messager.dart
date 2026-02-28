enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String chatId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.status,
  });

  ChatMessage copyWith({MessageStatus? status}) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
