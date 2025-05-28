import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/api_services.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String? folderId;

  const NoteEditorScreen({Key? key, this.noteId, this.folderId}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final ApiService api = ApiService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      loadNoteContent();
    }
  }

  Future<void> loadNoteContent() async {
    setState(() => isLoading = true);
    try {
      final res = await api.get('/api/Note/notes content/${widget.noteId}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _titleController.text = data['noteTitle'] ?? '';
        _contentController.text = data['content'] ?? '';
      }
    } catch (e) {
      print("Error loading note content: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty || widget.folderId == null) return;

    setState(() => isLoading = true);

    try {
      await api.post('/api/Note/create', {
        "folderId": widget.folderId,
        "noteTitle": title,
        "content": content
      });
      Navigator.pop(context);
    } catch (e) {
      print("Error saving note: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.noteId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '✍️ New Note' : '📝 Edit Note', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Note", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: saveNote,
            )
          ],
        ),
      ),
    );
  }
}


