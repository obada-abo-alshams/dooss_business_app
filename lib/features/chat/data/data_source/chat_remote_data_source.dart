import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> fetchChats();
  Future<List<ChatModel>> fetchArchivedChats();
  Future<ChatModel> createChat(int dealerUserId);
  Future<List<MessageModel>> fetchMessages(int chatId);
  Future<MessageModel> sendMessage(int chatId, String content);
  Future<ChatModel> archiveChat(int chatId);
  Future<ChatModel> unarchiveChat(int chatId);
}
