import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../service/api_services.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({Key? key, required this.subjectId}) : super(key: key);

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  WebSocketChannel? _channel;
  String? currentUserId;
  String? jwt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _loadTokenAndUser();
    await _fetchMessages();
    _connectWebSocket();
  }

  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('token');

    if (jwt != null) {
      final payload = json.decode(
        utf8.decode(base64.decode(base64.normalize(jwt!.split('.')[1]))),
      );
      currentUserId = payload['sub'];
    }
  }

  Future<void> _fetchMessages() async {
    final api = ApiService();
    final response = await api.get('/api/Topic/${widget.subjectId}/messages');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.addAll(List<Map<String, dynamic>>.from(data));
        isLoading = false;
      });
    }
  }

  void _connectWebSocket() {
    if (jwt == null) return;

    final wsUrl = Uri.parse('ws://localhost:8181/?access_token=$jwt');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((data) {
      final messageData = jsonDecode(data);

      // Filter only messages for this topic
      if (messageData['topicId'] == widget.subjectId) {
        setState(() {
          _messages.add(messageData);
        });
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || currentUserId == null) return;

    final messagePayload = {
      'eventType': 'SendTopicMessageDto',
      'topicId': widget.subjectId,
      'content': content,
      'requestId': const Uuid().v4(),
    };

    _channel?.sink.add(jsonEncode(messagePayload));
    _messageController.clear();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(Map<String, dynamic> msg) {
    final bool isMine = msg['senderId'] == currentUserId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMine ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isMine ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      backgroundColor: const Color(0xFFF5F0FF),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      fillColor: Colors.white,
                      filled: true,
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
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF6A1B9A),
                  ),
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
