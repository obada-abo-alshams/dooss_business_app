import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

class ChatState {
  final List<ChatModel> chats;
  final List<ChatModel> archivedChats;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMessages;
  final bool isLoadingArchivedChats;
  final String? error;
  final int? selectedChatId;
  final bool isWebSocketConnected;
  final bool isCreatingChat;

  const ChatState({
    this.chats = const [],
    this.archivedChats = const [],
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMessages = false,
    this.isLoadingArchivedChats = false,
    this.error,
    this.selectedChatId,
    this.isWebSocketConnected = false,
    this.isCreatingChat = false,
  });

  ChatState copyWith({
    List<ChatModel>? chats,
    List<ChatModel>? archivedChats,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMessages,
    bool? isLoadingArchivedChats,
    String? error,
    int? selectedChatId,
    bool? isWebSocketConnected,
    bool? isCreatingChat,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      archivedChats: archivedChats ?? this.archivedChats,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingArchivedChats: isLoadingArchivedChats ?? this.isLoadingArchivedChats,
      error: error,
      selectedChatId: selectedChatId,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
      isCreatingChat: isCreatingChat ?? this.isCreatingChat,
    );
  }
}
