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

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _handleResult();
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
      backgroundColor: const Color(0xFFF7F8F3),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green.shade700),
            const SizedBox(height: 18),
            Text(
              widget.loadingMessage,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
