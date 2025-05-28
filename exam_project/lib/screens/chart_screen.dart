import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_type.dart';
import '../service/api_services.dart';

class ChatScreen extends StatefulWidget {
  final ChatType chatType;
  final String targetId; // friendId or groupId
  final String displayName;

  const ChatScreen({
    Key? key,
    required this.chatType,
    required this.targetId,
    required this.displayName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  WebSocketChannel? _channel;
  String? jwt;
  String? currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _loadUser();
    await _fetchMessageHistory();
    _connectSocket();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('token');
    if (jwt != null) {
      final payload = json.decode(
        utf8.decode(base64.decode(base64.normalize(jwt!.split('.')[1]))),
      );
      currentUserId = payload['sub'];
    }
  }

  Future<void> _fetchMessageHistory() async {
    final api = ApiService();
    final endpoint = widget.chatType == ChatType.private
        ? '/api/Message/private/history?userBId=${widget.targetId}'
        : '/api/GroupChat/${widget.targetId}/messages';

    final response = await api.get(endpoint);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.addAll(List<Map<String, dynamic>>.from(data));
        isLoading = false;
      });
    }
  }

  void _connectSocket() {
    if (jwt == null) return;
    final wsUrl = Uri.parse('ws://localhost:8181/?access_token=$jwt');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((data) {
      final msg = jsonDecode(data);
      if (_isRelevantMessage(msg)) {
        setState(() {
          _messages.add(msg);
        });

        // Send delivery confirmation
        _sendSocketEvent('MarkMessageAsDeliveredDto', {
          "messageId": msg['id'],
        });
      }
    });
  }

  bool _isRelevantMessage(Map msg) {
    if (widget.chatType == ChatType.private) {
      return (msg['senderId'] == widget.targetId || msg['toUserId'] == widget.targetId);
    } else {
      return msg['groupId'] == widget.targetId;
    }
  }

  void _sendSocketEvent(String eventType, Map<String, dynamic> data) {
    final payload = {
      'eventType': eventType,
      ...data,
      'requestId': const Uuid().v4(),
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || currentUserId == null) return;

    final eventType = widget.chatType == ChatType.private
        ? 'SendPrivateMessageDto'
        : 'SendGroupMessageDto';

    final data = widget.chatType == ChatType.private
        ? {
      "toUserId": widget.targetId,
      "content": content,
    }
        : {
      "groupId": widget.targetId,
      "content": content,
    };

    _sendSocketEvent(eventType, data);
    _messageController.clear();
  }

  void _editMessage(String messageId, String newContent) {
    _sendSocketEvent("EditMessageDto", {
      "messageId": messageId,
      "newContent": newContent,
    });
  }

  void _deleteMessage(String messageId) {
    _sendSocketEvent("DeleteMessageDto", {
      "messageId": messageId,
    });
    setState(() {
      _messages.removeWhere((m) => m['id'] == messageId);
    });
  }

  void _markAsRead(String messageId) {
    _sendSocketEvent("MarkMessageAsReadDto", {
      "messageId": messageId,
    });
  }

  Widget _buildMessageItem(Map msg) {
    final bool isMine = msg['senderId'] == currentUserId;
    final messageId = msg['id'];

    return GestureDetector(
      onLongPress: isMine
          ? () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(messageId, "Edited message content");
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(messageId);
                },
              ),
            ],
          ),
        );
      }
          : () => _markAsRead(messageId),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMine ? Colors.deepPurple.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            msg['content'] ?? '',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayName)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessageItem(_messages[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
