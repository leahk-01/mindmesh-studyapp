import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../service/api_services.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> topics = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserTopics();
  }

  Future<void> fetchUserTopics() async {
    try {
      final api = ApiService();
      final response = await api.get('/api/Topic/user-topics');

      if (response.statusCode == 200) {
        setState(() {
          topics = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load subscribed topics');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text("Dashboard" , style: TextStyle(color: Colors.white)),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add More Subjects',
            onPressed: () => context.push('/subjects'),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile / Chat',
            onPressed: () => context.push('/chat-hub'),
          ),
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/folderscreen'),
        child: const Icon(Icons.folder),
        tooltip: 'Notebook',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Text("Error: $error",
            style: const TextStyle(color: Colors.red)),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Subjects",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: topics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final topicId = topic['id'];
                  final topicName = topic['name'] ?? "Unnamed";

                  return GestureDetector(
                    onTap: () => context.go('/subject/$topicId'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          topicName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

