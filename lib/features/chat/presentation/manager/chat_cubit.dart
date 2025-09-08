import 'package:dooss_business_app/core/cubits/optimized_cubit.dart';
import 'chat_state.dart';
import '../../data/data_source/chat_remote_data_source.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/locator_service.dart' as di;
import '../../../../core/services/token_service.dart';

class ChatCubit extends OptimizedCubit<ChatState> {
  final ChatRemoteDataSource dataSource;
  final WebSocketService _webSocketService = di.sl<WebSocketService>();
  
  ChatCubit(this.dataSource) : super(const ChatState()) {
    print('ChatCubit - Initialized');
    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    _webSocketService.onConnected = () {
      print('✅ ChatCubit: WebSocket connected');
      safeEmit(state.copyWith(isWebSocketConnected: true));
    };

    _webSocketService.onDisconnected = () {
      print('🔌 ChatCubit: WebSocket disconnected');
      safeEmit(state.copyWith(isWebSocketConnected: false));
    };

    _webSocketService.onMessageReceived = (message) {
      print('📨 ChatCubit: Message received via WebSocket: $message');
      // Handle incoming message
      _handleIncomingMessage(message);
    };

    _webSocketService.onError = (error) {
      print('❌ ChatCubit: WebSocket error: $error');
      safeEmit(state.copyWith(error: 'WebSocket error: $error'));
    };
  }

  void loadChats() async {
    print('ChatCubit - loadChats() called');
    safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      print('ChatCubit - Calling dataSource.fetchChats()');
      final chats = await dataSource.fetchChats();
      print('ChatCubit - Received ${chats.length} chats from dataSource');
      safeEmit(state.copyWith(
        chats: chats,
        isLoading: false,
      ));
      print('ChatCubit - State updated with ${state.chats.length} chats');
    } catch (e) {
      print('ChatCubit error: $e');
      safeEmit(state.copyWith(error: 'Failed to load chats', isLoading: false));
    }
  }

  void loadMessages(int chatId) async {
    print('ChatCubit - loadMessages() called with chatId: $chatId');
    safeEmit(state.copyWith(isLoadingMessages: true, error: null, selectedChatId: chatId));
    try {
      print('ChatCubit - Calling dataSource.fetchMessages()');
      final messages = await dataSource.fetchMessages(chatId);
      print('ChatCubit - Received ${messages.length} messages from dataSource');
      safeEmit(state.copyWith(
        messages: messages,
        isLoadingMessages: false,
      ));
      print('ChatCubit - State updated with ${state.messages.length} messages');
    } catch (e) {
      print('ChatCubit loadMessages error: $e');
      safeEmit(state.copyWith(error: 'Failed to load messages', isLoadingMessages: false));
    }
  }

  void sendMessage(String content) async {
    print('ChatCubit - sendMessage() called with content: $content');
    if (state.selectedChatId == null) {
      print('ChatCubit - No selectedChatId, cannot send message');
      return;
    }
    
    try {
      print('ChatCubit - Calling dataSource.sendMessage()');
      final message = await dataSource.sendMessage(state.selectedChatId!, content);
      final updatedMessages = [...state.messages, message];
      safeEmit(state.copyWith(messages: updatedMessages));
      print('ChatCubit - Message sent successfully, state updated');
    } catch (e) {
      print('ChatCubit sendMessage error: $e');
      safeEmit(state.copyWith(error: 'Failed to send message'));
    }
  }

  void createChat(int dealerUserId) async {
    print('ChatCubit - createChat() called with dealerUserId: $dealerUserId');
    safeEmit(state.copyWith(isCreatingChat: true, error: null));
    
    try {
      final chat = await dataSource.createChat(dealerUserId);
      print('ChatCubit - Chat created successfully: ${chat.id}');
      
      // Add to chats list
      final updatedChats = [...state.chats, chat];
      safeEmit(state.copyWith(
        chats: updatedChats,
        selectedChatId: chat.id,
        isCreatingChat: false,
      ));
      
      // Connect to WebSocket
      _connectToWebSocket(chat.id);
      
    } catch (e) {
      print('ChatCubit createChat error: $e');
      safeEmit(state.copyWith(
        error: 'Failed to create chat: $e',
        isCreatingChat: false,
      ));
    }
  }

  void _connectToWebSocket(int chatId) async {
    final accessToken = await TokenService.getAccessToken();
    if (accessToken != null) {
      await _webSocketService.connect(chatId, accessToken);
    } else {
      print('❌ ChatCubit: No access token found, cannot connect to WebSocket');
      safeEmit(state.copyWith(error: 'No access token found'));
    }
  }

  void _handleIncomingMessage(String message) {
    try {
      // Parse incoming message and add to messages list
      // This will be implemented based on the actual message format
      print('ChatCubit: Handling incoming message: $message');
    } catch (e) {
      print('ChatCubit: Error handling incoming message: $e');
    }
  }

  void sendMessageViaWebSocket(String text) {
    if (!state.isWebSocketConnected) {
      print('ChatCubit: WebSocket not connected, cannot send message');
      safeEmit(state.copyWith(error: 'Not connected to chat server'));
      return;
    }
    
    _webSocketService.sendMessage(text);
  }

  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }

  void clearSelectedChat() {
    print('ChatCubit - clearSelectedChat() called');
    disconnectWebSocket();
    safeEmit(state.copyWith(
      selectedChatId: null,
      messages: [],
      isLoadingMessages: false,
    ));
  }

  @override
  Future<void> close() {
    _webSocketService.dispose();
    return super.close();
  }
}
