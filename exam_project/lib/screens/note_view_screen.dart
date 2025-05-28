import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/api_services.dart';

class NoteViewScreen extends StatefulWidget {
  final String noteId;
  const NoteViewScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  final ApiService api = ApiService();
  String title = '';
  String content = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    try {
      final res = await api.get('/api/Note/notes content/${widget.noteId}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          title = data['noteTitle'] ?? '';
          content = data['content'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading note: $e");
      setState(() => isLoading = false);
    }
  }

  void _goToEdit() {
    context.push('/note/edit/${widget.noteId}');
  }

  void _showShareDialog() {
    final TextEditingController _friendController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Share Note'),
        content: TextField(
          controller: _friendController,
          decoration: const InputDecoration(
            hintText: 'Enter friend\'s email or username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
            ),
            onPressed: () {
              final user = _friendController.text.trim();
              if (user.isNotEmpty) {
                Navigator.pop(ctx);
                _shareNoteWithUser(user);
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> _shareNoteWithUser(String user) async {
    try {
      final body = jsonEncode({
        "noteId": widget.noteId,
        "recipientUsername": user
      });

      final res = await api.post('/api/Note/share', body);
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note shared successfully!')),
        );
      } else {
        throw Exception("Failed to share note");
      }
    } catch (e) {
      print("Error sharing note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share note')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Note View', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _goToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _showShareDialog,
          ),
        ],

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFFF3E5F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(content,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

