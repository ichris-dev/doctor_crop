import 'dart:convert';
import 'package:agriconnect_v0/loadingpage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  final Widget homePage;

  const RegisterPage({super.key, required this.homePage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int currentPage = 0;
  bool _obscurePassword = true;

  void goNext() {
    if (fullNameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name and farm location"),
          backgroundColor: DoctorCropColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> registeUser() async {
    final String uri = "http://192.168.50.36:8000/register";
    final url = Uri.parse(uri);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullNameController.text.trim(),
          "phone_number": phoneController.text.trim(),
          "password": passwordController.text,
          "location": locationController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          final uid = data['user_id'];
          sessionNotifier.value = SessionUser(
            userId: uid,
            fullName: fullNameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
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

  void register() {
    if (phoneController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide your phone number and a password"),
          backgroundColor: DoctorCropColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final Future<bool> result = registeUser();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingPage(
          registrationFuture: result,
          onSuccess: widget.homePage,
          onFailure: RegisterPage(
            homePage: widget.homePage,
          ),
          loadingMessage: "Creating your Doctor Crop account...",
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
    locationController.dispose();
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
        child: Column(
          children: [
            // Top Step Indicator Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _stepIndicatorBadge(
                    step: 1,
                    title: "Farmer Info",
                    isActive: currentPage >= 0,
                    isCurrent: currentPage == 0,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: currentPage >= 1
                          ? DoctorCropColors.primary
                          : DoctorCropColors.border,
                    ),
                  ),
                  _stepIndicatorBadge(
                    step: 2,
                    title: "Account Security",
                    isActive: currentPage >= 1,
                    isCurrent: currentPage == 1,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                children: [
                  _nameStep(),
                  _accountStep(),
                ],
              ),
            ),

            // Pagination dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(0), const SizedBox(width: 8), _dot(1)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicatorBadge({
    required int step,
    required String title,
    required bool isActive,
    required bool isCurrent,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isActive
                ? DoctorCropColors.primary
                : DoctorCropColors.surfaceMuted,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? DoctorCropColors.primary
                  : DoctorCropColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            "$step",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : DoctorCropColors.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent
                ? DoctorCropColors.textPrimary
                : DoctorCropColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _nameStep() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepTitle(
                  icon: Icons.person_pin_rounded,
                  title: "Farmer Details",
                  subtitle: "Enter your real names and farm region in Rwanda.",
                ),

                const SizedBox(height: 24),

                const Text(
                  "Full Names",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: DoctorCropColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: fullNameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 14, color: DoctorCropColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: "e.g. Jean Damascene",
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      size: 19,
                      color: DoctorCropColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Farm Location / District",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: DoctorCropColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: locationController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 14, color: DoctorCropColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: "e.g. Musanze, Northern Province",
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      size: 19,
                      color: DoctorCropColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: goNext,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue to Account Details",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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

  Widget _accountStep() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepTitle(
                  icon: Icons.shield_outlined,
                  title: "Account Security",
                  subtitle: "Add your phone number and choose a secure password.",
                ),

                const SizedBox(height: 24),

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
                    hintText: "e.g. 0788 000 000",
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      size: 19,
                      color: DoctorCropColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Create Password",
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
                    hintText: "Create a password",
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

                const SizedBox(height: 32),

                // Clean, responsive dual action buttons without overflow
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text("Back"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text(
                          "Register Account",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
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
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: DoctorCropColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: DoctorCropColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DoctorCropColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: DoctorCropColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(int index) {
    final bool active = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 8,
      width: active ? 28 : 8,
      decoration: BoxDecoration(
        color: active ? DoctorCropColors.primary : DoctorCropColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
