class ChatModel {
  final int id;
  final String user;
  final String dealer;
  final String createdAt;
  final LastMessage? lastMessage;
  final String lastMessageText;
  final String? lastMessageAt;
  final int userUnreadCount;
  final int dealerUnreadCount;
  final bool isArchived;

  ChatModel({
    required this.id,
    required this.user,
    required this.dealer,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageText = '',
    this.lastMessageAt,
    this.userUnreadCount = 0,
    this.dealerUnreadCount = 0,
    this.isArchived = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? '',
      dealer: json['dealer'] ?? '',
      createdAt: json['created_at'] ?? '',
      lastMessage: json['last_message'] != null 
          ? LastMessage.fromJson(json['last_message']) 
          : null,
      lastMessageText: json['last_message_text'] ?? '',
      lastMessageAt: json['last_message_at'],
      userUnreadCount: json['user_unread_count'] ?? 0,
      dealerUnreadCount: json['dealer_unread_count'] ?? 0,
      isArchived: json['is_archived'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'dealer': dealer,
      'created_at': createdAt,
      'last_message': lastMessage?.toJson(),
      'last_message_text': lastMessageText,
      'last_message_at': lastMessageAt,
      'user_unread_count': userUnreadCount,
      'dealer_unread_count': dealerUnreadCount,
      'is_archived': isArchived,
    };
  }

  ChatModel copyWith({
    int? id,
    String? user,
    String? dealer,
    String? createdAt,
    LastMessage? lastMessage,
    String? lastMessageText,
    String? lastMessageAt,
    int? userUnreadCount,
    int? dealerUnreadCount,
    bool? isArchived,
  }) {
    return ChatModel(
      id: id ?? this.id,
      user: user ?? this.user,
      dealer: dealer ?? this.dealer,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      userUnreadCount: userUnreadCount ?? this.userUnreadCount,
      dealerUnreadCount: dealerUnreadCount ?? this.dealerUnreadCount,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class LastMessage {
  final int id;
  final String sender;
  final int senderId;
  final String text;
  final String type;
  final String status;
  final String imageUrl;
  final String fileUrl;
  final String? fileSize;
  final String timestamp;
  final bool isMine;

  LastMessage({
    required this.id,
    required this.sender,
    required this.senderId,
    required this.text,
    required this.type,
    required this.status,
    required this.imageUrl,
    required this.fileUrl,
    this.fileSize,
    required this.timestamp,
    required this.isMine,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'] ?? 0,
      sender: json['sender'] ?? '',
      senderId: json['sender_id'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? 'text',
      status: json['status'] ?? 'sent',
      imageUrl: json['image_url'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'],
      timestamp: json['timestamp'] ?? '',
      isMine: json['is_mine'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'sender_id': senderId,
      'text': text,
      'type': type,
      'status': status,
      'image_url': imageUrl,
      'file_url': fileUrl,
      'file_size': fileSize,
      'timestamp': timestamp,
      'is_mine': isMine,
    };
  }
} 