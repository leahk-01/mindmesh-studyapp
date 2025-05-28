import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/note.dart';
import '../service/api_services.dart';

class SharedNotesScreen extends StatefulWidget {
  const SharedNotesScreen({Key? key}) : super(key: key);

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  final ApiService api = ApiService();
  List<Note> sharedNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSharedNotes();
  }

  Future<void> loadSharedNotes() async {
    setState(() => isLoading = true);
    try {
      final res = await api.get('/api/Note/shared-with-me');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        sharedNotes = data.map((json) => Note.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error loading shared notes: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📤 Shared With Me", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sharedNotes.isEmpty
          ? const Center(child: Text("No shared notes found."))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: sharedNotes.length,
        itemBuilder: (context, index) {
          final note = sharedNotes[index];
          return Card(
            color: const Color(0xFFEDE7F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: const Icon(Icons.share, color: Colors.deepPurple),
              title: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/shared-note/${note.id}'),
            ),
          );
        },
      ),
    );
  }
}
