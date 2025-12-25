import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

// Message model
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String content;
  final String messageType;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime? readAt;
  final String status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.messageType = 'text',
    this.attachmentUrl,
    this.isRead = false,
    this.readAt,
    this.status = 'sent',
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverType: json['receiverType'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      attachmentUrl: json['attachmentUrl'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      status: json['status'] ?? 'sent',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'senderType': senderType,
    'receiverId': receiverId,
    'receiverType': receiverType,
    'content': content,
    'messageType': messageType,
    'attachmentUrl': attachmentUrl,
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  bool get isFromMe => false; // Will be set dynamically
}

// Conversation model
class Conversation {
  final String conversationId;
  final String partnerId;
  final String partnerType;
  final String partnerName;
  final String? partnerSpecialization;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final bool lastMessageIsFromMe;
  final int unreadCount;

  Conversation({
    required this.conversationId,
    required this.partnerId,
    required this.partnerType,
    required this.partnerName,
    this.partnerSpecialization,
    this.lastMessageContent,
    this.lastMessageTime,
    this.lastMessageIsFromMe = false,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] ?? {};
    final lastMessage = json['lastMessage'] ?? {};
    
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      partnerId: partner['id'] ?? '',
      partnerType: partner['type'] ?? '',
      partnerName: partner['name'] ?? 'Unknown',
      partnerSpecialization: partner['specialization'],
      lastMessageContent: lastMessage['content'],
      lastMessageTime: lastMessage['createdAt'] != null 
          ? DateTime.parse(lastMessage['createdAt']) 
          : null,
      lastMessageIsFromMe: lastMessage['isFromMe'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatService {
  static const String baseUrl = 'https://carebridge-xhnj.onrender.com';
  static const String apiUrl = '$baseUrl/api';
  
  final String authToken;
  final String userId;
  final String userType;
  
  io.Socket? _socket;
  bool _isConnected = false;
  
  // Stream controllers for real-time events
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController = StreamController<Map<String, bool>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, bool>> get onlineStatusStream => _onlineStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _isConnected;

  ChatService({
    required this.authToken,
    required this.userId,
    required this.userType,
  });

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // =====================
  // WEBSOCKET CONNECTION
  // =====================

  void connect() {
    if (_socket != null) return;

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': authToken})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectionController.add(true);
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionController.add(false);
      print('Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    // Listen for new messages
    _socket!.on('new_message', (data) {
      final message = ChatMessage.fromJson(data['message']);
      _messageController.add(message);
    });

    // Listen for message sent confirmation
    _socket!.on('message_sent', (data) {
      final message = ChatMessage.fromJson(data['message']);
      _messageController.add(message);
    });

    // Listen for typing indicators
    _socket!.on('user_typing', (data) {
      _typingController.add({
        'userId': data['userId'],
        'isTyping': true,
      });
    });

    _socket!.on('user_stopped_typing', (data) {
      _typingController.add({
        'userId': data['userId'],
        'isTyping': false,
      });
    });

    // Listen for online status
    _socket!.on('online_status', (data) {
      final Map<String, bool> status = {};
      (data as Map).forEach((key, value) {
        status[key.toString()] = value as bool;
      });
      _onlineStatusController.add(status);
    });

    _socket!.on('user_offline', (data) {
      _onlineStatusController.add({data['userId']: false});
    });

    // Listen for read receipts
    _socket!.on('messages_marked_read', (data) {
      // Handle read receipts - can update UI
      print('Messages marked read in ${data['conversationId']}');
    });

    // Error handling
    _socket!.on('error', (data) {
      print('Socket error: ${data['message']}');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // =====================
  // CONVERSATION MANAGEMENT
  // =====================

  void joinConversation(String partnerId, String partnerType) {
    _socket?.emit('join_conversation', {
      'partnerId': partnerId,
      'partnerType': partnerType,
    });
  }

  void leaveConversation(String partnerId) {
    _socket?.emit('leave_conversation', {
      'partnerId': partnerId,
    });
  }

  // =====================
  // SEND MESSAGE (WebSocket)
  // =====================

  void sendMessage({
    required String receiverId,
    required String receiverType,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? tempId,
  }) {
    _socket?.emit('send_message', {
      'tempId': tempId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      'messageType': messageType,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    });
  }

  // =====================
  // TYPING INDICATORS
  // =====================

  void startTyping(String partnerId) {
    _socket?.emit('typing_start', {'partnerId': partnerId});
  }

  void stopTyping(String partnerId) {
    _socket?.emit('typing_stop', {'partnerId': partnerId});
  }

  // =====================
  // READ RECEIPTS
  // =====================

  void markMessagesAsRead(String conversationId, String partnerId) {
    _socket?.emit('messages_read', {
      'conversationId': conversationId,
      'partnerId': partnerId,
    });
  }

  // =====================
  // ONLINE STATUS
  // =====================

  void checkOnlineStatus(List<String> userIds) {
    _socket?.emit('check_online', {'userIds': userIds});
  }

  // =====================
  // REST API METHODS
  // =====================

  // Get all conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/chat/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> conversations = data['conversations'] ?? [];
        return conversations
            .map((c) => Conversation.fromJson(c))
            .toList();
      } else {
        throw Exception('Failed to get conversations');
      }
    } catch (e) {
      throw Exception('Get conversations error: $e');
    }
  }

  // Get conversation history with a specific user
  Future<List<ChatMessage>> getConversation(
    String partnerId, 
    String partnerType, {
    int limit = 50,
    int skip = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/chat/$partnerId/$partnerType?limit=$limit&skip=$skip'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messages = data['messages'] ?? [];
        return messages
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      } else {
        throw Exception('Failed to get conversation');
      }
    } catch (e) {
      throw Exception('Get conversation error: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/chat/unread'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Send message via REST (fallback)
  Future<ChatMessage> sendMessageRest({
    required String receiverId,
    required String receiverType,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/chat/send'),
        headers: headers,
        body: json.encode({
          'receiverId': receiverId,
          'receiverType': receiverType,
          'content': content,
          'messageType': messageType,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatMessage.fromJson(data['message']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['msg'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Send message error: $e');
    }
  }

  // Mark conversation as read via REST
  Future<void> markAsReadRest(String conversationId) async {
    try {
      await http.patch(
        Uri.parse('$apiUrl/chat/$conversationId/read'),
        headers: headers,
      );
    } catch (e) {
      print('Mark as read error: $e');
    }
  }

  // =====================
  // CLEANUP
  // =====================

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _onlineStatusController.close();
    _connectionController.close();
  }
}
