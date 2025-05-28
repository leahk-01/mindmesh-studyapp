import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_services.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  Set<String> selectedFriendIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final api = ApiService();
    final response = await api.get('/api/Friend/all-friends');
    final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
    setState(() {
      friends = data;
      isLoading = false;
    });
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;
    final payload = json.decode(
      utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))),
    );
    return payload['sub'];
  }

  Future<void> _createGroup() async {
    final creatorId = await _getUserId();
    if (creatorId == null || _groupNameController.text.trim().isEmpty) return;

    final api = ApiService();
    await api.post('/api/GroupChat/create', {
      'creatorId': creatorId,
      'name': _groupNameController.text.trim(),
      'friendIds': selectedFriendIds.toList()
    });

    Navigator.pop(context); // go back after creation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F9),
      appBar: AppBar(
        title: const Text("👥 Create Group", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD1C4E9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: "Group Name",
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Friends:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (_, i) {
                  final friend = friends[i];
                  final friendId = friend['id'];
                  final isSelected = selectedFriendIds.contains(friendId);
                  return Card(
                    color: const Color(0xFFF5EBFF),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      title: Text(friend['username'] ?? ''),
                      value: isSelected,
                      activeColor: const Color(0xFF6A1B9A),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedFriendIds.add(friendId);
                          } else {
                            selectedFriendIds.remove(friendId);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.check),
                label: const Text("Create Group"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
