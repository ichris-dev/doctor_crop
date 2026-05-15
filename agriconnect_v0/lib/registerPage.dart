import 'dart:convert';

import 'package:agriconnect_v0/loadingpage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  final Widget homePage;

  const RegisterPage({super.key, required this.homePage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  int currentPage = 0;

  void goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Map<String, String> message = {"message": "Loading market..."};

  // Change fetchUsers return type to Future<bool>
  Future<bool> registeUser() async {
    final String uri = "http://192.168.50.36:8000/register";
    final url = Uri.parse(uri);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullNameController.text,
          "phone_number": phoneController.text,
          "password": passwordController.text,
          "location": locationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final uid = data['user_id'];
          sessionNotifier.value = SessionUser(
            userId: uid,
            fullName: fullNameController.text,
            phoneNumber: phoneController.text,
          );
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Change register() to pass the future to LoadingPage
  void register() {
    final Future<bool> result = registeUser(); // start the call, don't await

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingPage(
          registrationFuture: result,
          onSuccess: widget.homePage, // goes to home if true
          onFailure: RegisterPage(
            homePage: widget.homePage,
          ), // back to register if false
          loadingMessage: "Creating your account...",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF7F8F3),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xffF7F8F3),
      body: SafeArea(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  children: [_nameStep(), _accountStep()],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(0), const SizedBox(width: 8), _dot(1)],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameStep() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle(
              icon: Icons.person_outline,
              title: "Your Address",
              subtitle: "Enter your real names to continue.",
            ),

            const SizedBox(height: 28),

            _input(
              controller: fullNameController,
              label: "Full names",
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 16),

            _input(
              controller: locationController,
              label: "Location",
              icon: Icons.location_on,
            ),

            const Spacer(),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 45,
                child: ElevatedButton(
                  onPressed: goNext,
                  style: _mainButtonStyle(),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountStep() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle(
              icon: Icons.lock_outline,
              title: "Account details",
              subtitle: "Add your phone number and password.",
            ),

            const SizedBox(height: 26),

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

            const Spacer(),

            Row(
              spacing: 70,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: _mainButtonStyle(isBack: true),

                    child: Row(
                      spacing: 20,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 15,
                          color: Colors.orange.shade800,
                        ),
                        Text(
                          "Back",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: register,
                    style: _mainButtonStyle(),
                    child: const Text(
                      "Register",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        labelStyle: TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.green.shade700, size: 15),
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

  Widget _dot(int index) {
    final bool active = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 8,
      width: active ? 28 : 8,
      decoration: BoxDecoration(
        color: active ? Colors.greenAccent.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
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

  ButtonStyle _mainButtonStyle({bool isBack = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isBack
          ? Colors.transparent
          : Colors.greenAccent.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      side: isBack
          ? BorderSide(color: Colors.orange.shade800, width: 1)
          : BorderSide.none,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
