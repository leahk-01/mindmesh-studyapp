import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/folder.dart';
import '../service/api_services.dart';

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({Key? key}) : super(key: key);

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final ApiService api = ApiService();
  final TextEditingController _folderNameController = TextEditingController();
  List<Folder> folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get('/api/Note/folders-names-for-user');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        folders = data.map((json) => Folder.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading folders: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _createFolder(String name) async {
    try {
      await api.post('/api/Note/new folder', jsonEncode(name));
      _folderNameController.clear();
      _loadFolders();
    } catch (e) {
      print('Error creating folder: $e');
    }
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Create New Folder'),
        content: TextField(
          controller: _folderNameController,
          decoration: const InputDecoration(
            hintText: 'Enter folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _folderNameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                _createFolder(name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A), // purple
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📓 My Notebook', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A), // deep purple
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              tooltip: 'Shared With Me',
              onPressed: () => context.push('/shared'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadFolders,
            ),
          ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : folders.isEmpty
          ? const Center(child: Text('No folders found.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Folders (${folders.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: folders.length,
              itemBuilder: (ctx, i) {
                final folder = folders[i];
                return Card(
                  color: const Color(0xFFD1C4E9), // lavender
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: const Icon(Icons.folder, color: Colors.orangeAccent),
                    title: Text(
                      folder.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/folder/${folder.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFolderDialog,
        icon: const Icon(Icons.create_new_folder),
        label: const Text('New Folder'),
      ),
    );
  }
}

