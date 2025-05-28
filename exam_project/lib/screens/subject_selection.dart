import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../service/api_services.dart';

class SubjectSelectionScreen extends StatefulWidget {
  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  List<dynamic> allTopics = [];
  List<dynamic> userTopics = [];
  Set<String> selectedTopics = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      final api = ApiService();

      final allResp = await api.get('/api/Topic/all-topics');
      final userResp = await api.get('/api/Topic/user-topics');

      if (allResp.statusCode == 200 && userResp.statusCode == 200) {
        final all = jsonDecode(allResp.body) as List;
        final user = jsonDecode(userResp.body) as List;

        final userIds = user.map((t) => t['id']).toSet();

        final available = all.where((t) => !userIds.contains(t['id'])).toList();

        setState(() {
          allTopics = available;
          userTopics = user;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Something went wrong: ${e.toString()}';
      });
    }
  }

  Future<void> subscribeToTopics() async {
    if (selectedTopics.isEmpty) return;

    final api = ApiService();
    final response = await api.post('/api/Topic/subscribe', {
      'topicIds': selectedTopics.toList()
    });

    if (response.statusCode == 200) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscription failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text("Choose Your Subjects", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allTopics.isEmpty
          ? const Center(child: Text("You’ve already subscribed to all available subjects."))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allTopics.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final topic = allTopics[index];
                final id = topic['id'];
                final name = topic['name'] ?? 'Untitled';

                final isSelected = selectedTopics.contains(id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? selectedTopics.remove(id)
                          : selectedTopics.add(id);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Color(0xFF6A1B9A)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Color(0xFF6A1B9A)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: subscribeToTopics,
              child: const Text("Continue to Dashboard", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}


