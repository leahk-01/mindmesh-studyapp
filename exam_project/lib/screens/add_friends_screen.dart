import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/api_services.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> suggestions = [];
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  Future<void> _loadFriendsData() async {
    final api = ApiService();

    try {
      final pendingRes = await api.get('/api/Friend/pending-requests');

      setState(() {
        if (pendingRes.body.isNotEmpty) {
          pendingRequests = List<Map<String, dynamic>>.from(jsonDecode(pendingRes.body));
        } else {
          pendingRequests = [];
        }

        suggestions = [];

        isLoading = false;
      });
    } catch (e) {
      print('Error loading friends data: $e');
      setState(() {
        pendingRequests = [];
        suggestions = [];
        isLoading = false;
      });
    }
  }

  Future<void> _sendRequest(String userId) async {
    final api = ApiService();
    await api.post('/api/Friend/request', {"toUserId": userId});
    _loadFriendsData();
  }

  Future<void> _accept(String userId) async {
    final api = ApiService();
    await api.post('/api/Friend/accept', {"toUserId": userId});
    _loadFriendsData();
  }

  Future<void> _reject(String userId) async {
    final api = ApiService();
    await api.post('/api/Friend/reject-request', {"toUserId": userId});
    _loadFriendsData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSuggestions = suggestions.where((user) {
      final username = (user['username'] ?? '').toLowerCase();
      return username.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F9),
      appBar: AppBar(
        title: const Text("Add Friends", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadFriendsData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Added Me", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (pendingRequests.isEmpty)
              const Text("No pending requests.", style: TextStyle(color: Colors.grey)),
            ...pendingRequests.map((req) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(req['username'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _accept(req['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _reject(req['id']),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            const Text("Find Friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (filteredSuggestions.isEmpty)
              const Text("No users found.", style: TextStyle(color: Colors.grey)),
            ...filteredSuggestions.map((user) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(user['username']),
                trailing: ElevatedButton(
                  onPressed: () => _sendRequest(user['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                  ),
                  child: const Text("Add"),
                ),
              ),
            )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
