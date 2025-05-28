import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../service/api_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final api = ApiService();
      final response = await api.unauthPost('/api/User/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final jwt = jsonDecode(response.body)['jwt'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', jwt);

        final topicResponse = await api.get('/api/Topic/user-topics');
        if (topicResponse.statusCode == 200) {
          final topics = jsonDecode(topicResponse.body);
          if (topics.isEmpty) {
            context.go('/subjects');
          } else {
            context.go('/dashboard');
          }
        } else {
          throw Exception('Failed to check topics');
        }
      } else {
        setState(() {
          errorText = 'Login failed. Check your email or password.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = 'Something went wrong: ${e.toString()}';
      });
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                " MindMesh!",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 16),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(errorText!,
                      style: const TextStyle(color: Colors.red)),
                ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white,)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}