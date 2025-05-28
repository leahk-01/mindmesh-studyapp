import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service/api_services.dart';

class NotesInFolderScreen extends StatefulWidget {
  final String folderId;
  const NotesInFolderScreen({Key? key, required this.folderId}) : super(key: key);

  @override
  State<NotesInFolderScreen> createState() => _NotesInFolderScreenState();
}

class _NotesInFolderScreenState extends State<NotesInFolderScreen> {
  final ApiService api = ApiService();
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNoteTitles();
  }

  Future<void> loadNoteTitles() async {
    setState(() => isLoading = true);
    try {
      final res = await api.get('/api/Note/notes titles in folder/${widget.folderId}');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          notes = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Error loading notes: $e");
    }
    setState(() => isLoading = false);
  }

  void openNoteScreen(String noteId) {
    context.push('/note/view/$noteId');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text('No notes found.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notes (${notes.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: notes.length,
              itemBuilder: (ctx, i) {
                final note = notes[i];
                return Card(
                  color: const Color(0xFFF3E5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: const Icon(Icons.note, color: Colors.deepPurple),
                    title: Text(
                      note['title'] ?? 'Untitled',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => openNoteScreen(note['id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/note/new', extra: widget.folderId),
        icon: const Icon(Icons.note_add),
        label: const Text('New Note'),
      ),
    );
  }
}
