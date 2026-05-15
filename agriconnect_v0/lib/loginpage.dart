// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:agriconnect_v0/loadingpage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/registerPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final Widget homePage;
  const LoginPage({super.key, required this.homePage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> loginUser() async {
    final response = await http.post(
      Uri.parse("http://192.168.50.36:8000/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone_number": phoneController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        final user = data['user_data']; // now a single dict
        sessionNotifier.value = SessionUser(
          userId: user['user_id'],
          fullName: user['full_name'],
          phoneNumber: phoneController.text,
        );
        return true;
      }
    }
    return false;
  }

  // Update login() to call both in parallel
  void login() async {
    final bool success = await loginUser();
    if (!mounted) return;

    if (success) {
      final user = sessionNotifier.value;
      if (user != null) {
        await Future.wait([
          fetchUsersExceptCurrentUser(user.phoneNumber),
          fetchUserStore(user.phoneNumber),
        ]);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.homePage),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong phone number or password"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Add this method
  Future<void> fetchUserStore(String phoneNumber) async {
    final url = Uri.parse("http://192.168.50.36:8000/fetch-store");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("STORE RESPONSE: $data"); // remove after confirming it works

      if (data['success'] == true && data['store'] != null) {
        final products = (data['products'] as List)
            .map((p) => StoreProduct.fromJson(p as Map<String, dynamic>))
            .toList();

        storeSessionNotifier.value = StoreSession.fromJson(
          data['store'] as Map<String, dynamic>,
          products,
        );
      } else {
        storeSessionNotifier.value = null;
      }
    }
  }

  Future<void> fetchUsersExceptCurrentUser(String phoneNumber) async {
    final url = Uri.parse("http://192.168.50.36:8000/fetch-all");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final all_users = data['users'];
      final all_chats = data['chats'];

      print(all_users);
      fetchedUsers.value = all_users
          .map((item) => UserInfo.fromJson(item as Map<String, dynamic>))
          .toList()
          .cast<UserInfo>();

      fetchChats.value = all_chats
          .map((chat) => UserChats.fromJson(chat as Map<String, dynamic>))
          .toList()
          .cast<UserChats>();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepTitle(
                  icon: Icons.lock_outline,
                  title: "Welcome back",
                  subtitle: "Login using your phone number and password.",
                ),

                const SizedBox(height: 30),

                _input(
                  controller: phoneController,
                  label: "Phone number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                _input(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: login,
                    style: _mainButtonStyle(),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterPage(homePage: widget.homePage),
                        ),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Don’t have an account? ",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              color: Colors.greenAccent.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.orange.shade800),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.green, size: 15),
        filled: true,
        fillColor: const Color(0xffF7F8F3),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.greenAccent.shade700,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  ButtonStyle _mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.greenAccent.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
