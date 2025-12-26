import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatService? _chatService;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isTyping = false;
  String? _partnerTyping;

  late String _partnerId;
  late String _partnerType;
  late String _partnerName;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _partnerId = args['partnerId'];
    _partnerType = args['partnerType'];
    _partnerName = args['partnerName'];

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final authService = AuthService();
    final token = await authService.getToken();

    if (user == null || token == null) return;

    // Initialize chat service
    _chatService = ChatService(
      authToken: token,
      userId: user.id,
      userType: user.role.name,
    );

    // Connect to WebSocket
    _chatService!.connect();

    // Listen for new messages
    _chatService!.messageStream.listen((message) {
      if ((message.senderId == _partnerId) || (message.senderId == user.id)) {
        setState(() {
        final index = _messages.indexWhere(
          (m) => m.id == message.id || m.content == message.content,
        );

        if (index != -1) {
          _messages[index] = message; // replace optimistic
        } else {
          _messages.add(message);
        }
      });
        _scrollToBottom();

        // Mark as read if from partner
        if (message.senderId == _partnerId &&
            message.conversationId.isNotEmpty) {
          _chatService!.markMessagesAsRead(message.conversationId, _partnerId);
        }
      }
    });

    // Listen for typing indicators
    _chatService!.typingStream.listen((data) {
      if (data['userId'] == _partnerId) {
        setState(() {
          _partnerTyping = data['isTyping'] == true ? _partnerName : null;
        });
      }
    });

    // Join conversation
    _chatService!.joinConversation(_partnerId, _partnerType);

    // Load existing messages
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_chatService == null) {
      print('❌ ChatService is null. Cannot load messages.');
      return;
    }

    try {
      print(
        '🔄 Loading messages for partnerId: $_partnerId, partnerType: $_partnerType',
      );
      setState(() => _isLoading = true);
      final conversationData = await _chatService!.getConversation(
        _partnerId,
        _partnerType,
      );
      print('✅ Messages loaded: ${conversationData.messages.length} messages');
      print('✅ Partner name from API: ${conversationData.partnerName}');
      setState(() {
        _messages = conversationData.messages;
        // Update partner name from API response
        if (conversationData.partnerName.isNotEmpty &&
            conversationData.partnerName != 'Unknown') {
          _partnerName = conversationData.partnerName;
        }
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e, stackTrace) {
      print('❌ Failed to load messages: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load messages: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleTyping() {
    if (_chatService == null) return;

    if (!_isTyping) {
      _isTyping = true;
      _chatService!.startTyping(_partnerId);
    }

    // Stop typing indicator after 2 seconds of no input
    Future.delayed(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _chatService!.stopTyping(_partnerId);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _chatService == null) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isSending = true);
    _messageController.clear();
    _isTyping = false;
    _chatService!.stopTyping(_partnerId);
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      // Send via WebSocket
      _chatService!.sendMessage(
        receiverId: _partnerId,
        receiverType: _partnerType,
        content: text,
        tempId: tempId,
      );

      // Add optimistic message
      final optimisticMessage = ChatMessage(
        id: tempId,
        conversationId: '',
        senderId: user.id,
        senderType: user.role.name,
        receiverId: _partnerId,
        receiverType: _partnerType,
        content: text,
        createdAt: DateTime.now(),
      );


      setState(() {
       if (!_chatService!.isConnected) {
          _messages.add(optimisticMessage);
        }
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  _partnerType.toLowerCase() == 'doctor'
                      ? Colors.green[100]
                      : Colors.blue[100],
              child: Text(
                _partnerName.isNotEmpty ? _partnerName[0].toUpperCase() : '?',
                style: TextStyle(
                  color:
                      _partnerType.toLowerCase() == 'doctor'
                          ? Colors.green[700]
                          : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partnerType.toLowerCase() == 'doctor'
                        ? 'Dr. $_partnerName'
                        : _partnerName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_partnerTyping != null)
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // TODO: Video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // TODO: Voice call
            },
          ),
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear chat'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send a message to start the conversation',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderId == user?.id;
                        final showDate =
                            index == 0 ||
                            !_isSameDay(
                              _messages[index - 1].createdAt,
                              message.createdAt,
                            );

                        return Column(
                          children: [
                            if (showDate)
                              _DateSeparator(date: message.createdAt),
                            _MessageBubble(
                              message: message,
                              isMe: isMe,
                              partnerName: _partnerName,
                            ),
                          ],
                        );
                      },
                    ),
          ),

          // Typing indicator
          if (_partnerTyping != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypingIndicator(),
                        const SizedBox(width: 8),
                        Text(
                          '$_partnerTyping is typing...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Attach file
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      onChanged: (_) => _handleTyping(),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: Icon(
                        _isSending ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String partnerName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  message.senderType.toLowerCase() == 'doctor'
                      ? Colors.green[100]
                      : Colors.blue[100],
              child: Text(
                partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      message.senderType.toLowerCase() == 'doctor'
                          ? Colors.green[700]
                          : Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeFormat.format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color:
                              message.isRead
                                  ? Colors.blue[200]
                                  : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
              ),
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * animation.value),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
