// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/registerPage.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
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
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<bool> loginUser() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.50.36:8000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneController.text.trim(),
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final user = data['user_data'];
          sessionNotifier.value = SessionUser(
            userId: user['user_id'],
            fullName: user['full_name'],
            phoneNumber: phoneController.text.trim(),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void login() async {
    if (phoneController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both phone number and password"),
          backgroundColor: DoctorCropColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bool success = await loginUser();
    if (!mounted) return;

    if (success) {
      final user = sessionNotifier.value;
      if (user != null) {
        try {
          await Future.wait([
            fetchUsersExceptCurrentUser(user.phoneNumber),
            fetchUserStore(user.phoneNumber),
          ]);
        } catch (_) {}
      }
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.homePage),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid phone number or password. Please try again."),
          backgroundColor: DoctorCropColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> fetchUserStore(String phoneNumber) async {
    try {
      final url = Uri.parse("http://192.168.50.36:8000/fetch-store");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
    } catch (_) {}
  }

  Future<void> fetchUsersExceptCurrentUser(String phoneNumber) async {
    try {
      final url = Uri.parse("http://192.168.50.36:8000/fetch-all");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final all_users = data['users'] as List;
        final all_chats = data['chats'] as List;

        fetchedUsers.value = all_users
            .map((item) => UserInfo.fromJson(item as Map<String, dynamic>))
            .toList();

        fetchChats.value = all_chats
            .map((chat) => UserChats.fromJson(chat as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
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
      backgroundColor: DoctorCropColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DoctorCropColors.border, width: 0.8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: DoctorCropColors.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: DoctorCropTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: DoctorCropColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: DoctorCropColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: DoctorCropColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Doctor Crop Farmer Portal",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: DoctorCropColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Phone input
                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DoctorCropColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14, color: DoctorCropColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: "e.g. 0788 123 456",
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          size: 19,
                          color: DoctorCropColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Password input
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DoctorCropColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 14, color: DoctorCropColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 19,
                          color: DoctorCropColors.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 19,
                            color: DoctorCropColors.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password reset instructions have been forwarded to your registered phone number.",
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: DoctorCropColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorCropColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterPage(homePage: widget.homePage),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Don’t have an account? ",
                            style: TextStyle(
                              color: DoctorCropColors.textSecondary,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "Register Now",
                                style: TextStyle(
                                  color: DoctorCropColors.primary,
                                  fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}
