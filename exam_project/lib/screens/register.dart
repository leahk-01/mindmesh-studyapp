import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service/api_services.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;
  String? errorText;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    if (passwordController.text != confirmController.text) {
      setState(() {
        errorText = "Passwords do not match.";
        isLoading = false;
      });
      return;
    }

    try {
      final api = ApiService();
      final response = await api.unauthPost('/api/User/register', {
        'username': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully! Please login.")),
        );
        context.go('/');
      } else {
        setState(() {
          errorText = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorText = "An error occurred: ${e.toString()}";
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.app_registration, size: 64, color: Colors.purple),
              const SizedBox(height: 20),
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: purple,
                ),
              ),
              const SizedBox(height: 20),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white,)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text("Already have an account? Login here"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
