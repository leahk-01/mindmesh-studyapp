import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/api_services.dart';

class SharedNoteViewerScreen extends StatefulWidget {
  final String noteId;
  const SharedNoteViewerScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  State<SharedNoteViewerScreen> createState() => _SharedNoteViewerScreenState();
}

class _SharedNoteViewerScreenState extends State<SharedNoteViewerScreen> {
  final ApiService api = ApiService();
  String title = '';
  String content = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNote();
  }

  Future<void> loadNote() async {
    try {
      final res = await api.get('/api/Note/notes content/${widget.noteId}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        title = data['noteTitle'] ?? '';
        content = data['content'] ?? '';
      }
    } catch (e) {
      print("Error loading shared note: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.isEmpty ? "Shared Note" : title),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
