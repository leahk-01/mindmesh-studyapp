import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/chat_type.dart';
import '../service/api_services.dart';
import 'chart_screen.dart';

class ChatHubScreen extends StatefulWidget {
  const ChatHubScreen({Key? key}) : super(key: key);

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends State<ChatHubScreen> {
  List<Map<String, dynamic>> allChats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final api = ApiService();
    final fRes = await api.get('/api/Friend/all-friends');
    final gRes = await api.get('/api/GroupChat/all-my-groups');

    final friends = List<Map<String, dynamic>>.from(jsonDecode(fRes.body));
    final groups = List<Map<String, dynamic>>.from(jsonDecode(gRes.body));

    setState(() {
      allChats = [
        ...friends.map((f) => {
          "id": f['id'],
          "name": f['username'],
          "type": ChatType.private,
        }),
        ...groups.map((g) => {
          "id": g['id'],
          "name": g['name'],
          "type": ChatType.group,
        }),
      ];
      isLoading = false;
    });
  }

  void _openBottomMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add, color: Color(0xFF6A1B9A)),
              title: const Text('New Group Chat'),
              onTap: () {
                Navigator.pop(context);
                context.push('/create-group');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF6A1B9A)),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToChat(String id, String name, ChatType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(chatType: type, targetId: id, displayName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 2,
        centerTitle: true,
        title: const Text("💬 Chats", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF6A1B9A)),
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt, color: Colors.white),
            onPressed: () => context.push('/add-friends'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _openBottomMenu,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadChats,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: allChats.length,
          itemBuilder: (_, index) {
            final chat = allChats[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFFD1C4E9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6A1B9A),
                  child: Text(
                    chat['name'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  chat['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF6A1B9A)),
                onTap: () => _goToChat(chat['id'], chat['name'], chat['type']),
              ),
            );
          },
        ),
      ),
    );
  }
}
