import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final Future<bool> registrationFuture;
  final Widget onSuccess;
  final Widget onFailure;
  final String loadingMessage;

  const LoadingPage({
    super.key,
    required this.registrationFuture,
    required this.onSuccess,
    required this.onFailure,
    this.loadingMessage = "Creating your account...",
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _handleResult();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleResult() async {
    final bool success = await widget.registrationFuture;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => success ? widget.onSuccess : widget.onFailure,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: DoctorCropColors.primary.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 38,
                    color: DoctorCropColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DoctorCropColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DoctorCropColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Connecting securely with Doctor Crop services",
                style: TextStyle(
                  fontSize: 12,
                  color: DoctorCropColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
