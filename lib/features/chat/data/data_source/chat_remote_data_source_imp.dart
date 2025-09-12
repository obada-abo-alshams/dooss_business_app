import 'package:dooss_business_app/core/network/api.dart';
import 'package:dooss_business_app/core/network/api_request.dart';
import 'package:dooss_business_app/core/network/api_urls.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'chat_remote_data_source.dart';

class ChatRemoteDataSourceImp implements ChatRemoteDataSource {
  final API api;
  
  ChatRemoteDataSourceImp({required this.api});

  @override
  Future<List<ChatModel>> fetchChats() async {
    try {
      print('Fetching chats from API...');
      final response = await api.get(
        apiRequest: ApiRequest(url: ApiUrls.chats),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          return <ChatModel>[];
        },
        (data) {
          print('Data received: $data');
          if (data is List) {
            return data.map((e) => ChatModel.fromJson(e)).toList();
          } else {
            print('Invalid data format received from API');
            return <ChatModel>[];
          }
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource error: $e');
      return <ChatModel>[];
    }
  }

  @override
  Future<ChatModel> createChat(int dealerUserId) async {
    try {
      print('Creating chat with dealer: $dealerUserId');
      final response = await api.post(
        apiRequest: ApiRequest(
          url: ApiUrls.chats,
          data: {'dealer_user_id': dealerUserId},
        ),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          throw Exception('Failed to create chat: ${failure.message}');
        },
        (data) {
          print('Chat created successfully: $data');
          return ChatModel.fromJson(data);
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource createChat error: $e');
      throw Exception('Failed to create chat: $e');
    }
  }

  @override
  Future<List<MessageModel>> fetchMessages(int chatId) async {
    try {
      print('Fetching messages from API...');
      final url = '${ApiUrls.chats}$chatId/messages/';
      print('Constructed URL: $url');
      final response = await api.get(
        apiRequest: ApiRequest(url: url),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          return <MessageModel>[];
        },
        (data) {
          print('Data received: $data');
          if (data is Map && data['results'] is List) {
            final results = data['results'] as List;
            return results.map((e) => MessageModel.fromJson(e)).toList();
          } else if (data is List) {
            return data.map((e) => MessageModel.fromJson(e)).toList();
          } else {
            print('Invalid data format received from API');
            return <MessageModel>[];
          }
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource fetchMessages error: $e');
      return <MessageModel>[];
    }
  }

  @override
  Future<MessageModel> sendMessage(int chatId, String content) async {
    try {
      print('Sending message to API...');
      final response = await api.post(
        apiRequest: ApiRequest(
          url: '${ApiUrls.chats}$chatId/messages/',
          data: {'text': content}, // Changed from 'content' to 'text'
        ),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          throw Exception('Failed to send message');
        },
        (data) {
          print('Data received: $data');
          return MessageModel.fromJson(data);
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource sendMessage error: $e');
      throw Exception('Failed to send message');
    }
  }

  @override
  Future<List<ChatModel>> fetchArchivedChats() async {
    try {
      print('Fetching archived chats from API...');
      final response = await api.get(
        apiRequest: ApiRequest(url: '${ApiUrls.chats}archived/'),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          return <ChatModel>[];
        },
        (data) {
          print('Data received: $data');
          if (data is List) {
            return data.map((e) => ChatModel.fromJson(e)).toList();
          } else {
            print('Invalid data format received from API');
            return <ChatModel>[];
          }
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource fetchArchivedChats error: $e');
      return <ChatModel>[];
    }
  }

  @override
  Future<ChatModel> archiveChat(int chatId) async {
    try {
      print('Archiving chat with ID: $chatId');
      final response = await api.patch(
        apiRequest: ApiRequest(
          url: '${ApiUrls.chats}$chatId/archive/',
          data: {'is_archived': true},
        ),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          throw Exception('Failed to archive chat: ${failure.message}');
        },
        (data) {
          print('Chat archived successfully: $data');
          return ChatModel.fromJson(data);
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource archiveChat error: $e');
      throw Exception('Failed to archive chat: $e');
    }
  }

  @override
  Future<ChatModel> unarchiveChat(int chatId) async {
    try {
      print('Unarchiving chat with ID: $chatId');
      final response = await api.patch(
        apiRequest: ApiRequest(
          url: '${ApiUrls.chats}$chatId/unarchive/',
          data: {'is_archived': false},
        ),
      );
      print('API response: $response');
      return response.fold(
        (failure) {
          print('Failure: ${failure.message}');
          throw Exception('Failed to unarchive chat: ${failure.message}');
        },
        (data) {
          print('Chat unarchived successfully: $data');
          return ChatModel.fromJson(data);
        },
      );
    } catch (e) {
      print('ChatRemoteDataSource unarchiveChat error: $e');
      throw Exception('Failed to unarchive chat: $e');
    }
  }
}
