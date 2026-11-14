// ignore_for_file: deprecated_member_use, unnecessary_underscores, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────
  String? _selectedCrop = "Potato";
  final Map<String, File?> _cropImages = {
    'Potato': null,
    'Maize': null,
    'Beans': null,
  };
  bool _isUploading = false;
  String? _uploadError;

  Map<String, dynamic>? _predictionResult;
  List<dynamic> _allPredictions = [];
  bool _resultReady = false;

  File? get _capturedImage {
    if (_selectedCrop == null) return null;
    return _cropImages[_selectedCrop];
  }

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _crops = [
    {
      'name': 'Potato',
      'icon': Icons.eco_rounded,
      'color': DoctorCropColors.primary,
      'description': 'Irish & Sweet Potato',
    },
    {
      'name': 'Maize',
      'icon': Icons.agriculture_rounded,
      'color': DoctorCropColors.accent,
      'description': 'Corn & Cereals',
    },
    {
      'name': 'Beans',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF0D9488),
      'description': 'Climbing & Bush Beans',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendImageData() async {
    if (_capturedImage == null || _selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a crop and take a photo first"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _uploadError = null;
        _resultReady = false;
      });

      final createdTime = DateTime.now().toIso8601String();
      final url = Uri.parse("http://192.168.50.36:8000/upload-image");
      final request = http.MultipartRequest("POST", url);

      request.fields["crop"] = _selectedCrop!;
      request.fields["phone_path"] = _capturedImage!.path;
      request.fields["created_time"] = createdTime;

      request.files.add(
        await http.MultipartFile.fromPath("image", _capturedImage!.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 && decoded["prediction"] != null) {
        final prediction = decoded["prediction"];

        setState(() {
          _predictionResult = prediction;
          _allPredictions = prediction["all_probabilities"] ?? [];
          _resultReady = true;
          _isUploading = false;
        });
        _fadeController.forward(from: 0.0);

        // Scroll to results
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        setState(() {
          _uploadError = decoded.toString();
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = "Detection service currently unreachable: $e";
        _isUploading = false;
      });
    }
  }

  Future<void> _captureImage(ImageSource source) async {
    if (_selectedCrop == null) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (file != null) {
      setState(() {
        _cropImages[_selectedCrop!] = File(file.path);
        _resultReady = false;
        _uploadError = null;
        _fadeController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _buildIntroSection(),
            const SizedBox(height: 16),
            _buildCropSelector(),
            const SizedBox(height: 16),
            _buildCameraSection(),

            if (_uploadError != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DoctorCropColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DoctorCropColors.error.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: DoctorCropColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: const TextStyle(
                          color: DoctorCropColors.error,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_capturedImage != null && !_resultReady) ...[
              const SizedBox(height: 16),
              _buildAnalyzeButton(),
            ],

            if (_resultReady) ...[
              const SizedBox(height: 20),
              _buildPredictionResults(),
              const SizedBox(height: 16),
              _buildSubmitToAgronomist(),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorCropColors.primaryLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DoctorCropColors.primary.withOpacity(0.18),
          width: 0.9,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DoctorCropColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: DoctorCropColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Crop Diagnostics",
                  style: TextStyle(
                    color: DoctorCropColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "1. Select crop variety  •  2. Capture affected leaf  •  3. Instant AI diagnosis with verified treatment options.",
                  style: TextStyle(
                    color: DoctorCropColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "1. SELECT CROP VARIETY",
          style: TextStyle(
            color: DoctorCropColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _crops.map((crop) {
            final name = crop['name'] as String;
            final isSelected = _selectedCrop == name;
            final color = crop['color'] as Color;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCrop = name;
                    _resultReady = false;
                    _uploadError = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : DoctorCropColors.border,
                      width: isSelected ? 1.6 : 0.9,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.16),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        crop['icon'] as IconData,
                        color: isSelected ? color : DoctorCropColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? color : DoctorCropColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCameraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "2. CAPTURE LEAF PHOTO",
          style: TextStyle(
            color: DoctorCropColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _capturedImage != null
                  ? DoctorCropColors.primary
                  : DoctorCropColors.border,
              width: _capturedImage != null ? 1.5 : 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _capturedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_capturedImage!, fit: BoxFit.cover),

                    // Clear photo button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _cropImages[_selectedCrop!] = null;
                            _resultReady = false;
                            _uploadError = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Retake pill button
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.70),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Retake",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Opacity(
                        opacity: 0.6 + (_pulseController.value * 0.4),
                        child: child,
                      ),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: DoctorCropColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 30,
                          color: DoctorCropColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Take photo of $_selectedCrop leaf",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: DoctorCropColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ensure leaf is well-lit and fills the frame",
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorCropColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _captureImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                          label: const Text("Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DoctorCropColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _captureImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, size: 16),
                          label: const Text("Gallery"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Capture Crop Leaf Image",
                style: TextStyle(
                  color: DoctorCropColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Pick an option to provide a clear photo for diagnosis",
                style: TextStyle(
                  color: DoctorCropColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: DoctorCropColors.primary,
                  ),
                ),
                title: const Text(
                  "Take photo with camera",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                subtitle: const Text(
                  "Direct capture in natural sunlight",
                  style: TextStyle(fontSize: 11.5),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: DoctorCropColors.accent,
                  ),
                ),
                title: const Text(
                  "Choose from photo gallery",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                subtitle: const Text(
                  "Select a previously saved leaf photo",
                  style: TextStyle(fontSize: 11.5),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : sendImageData,
        icon: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text(
          _isUploading
              ? "Genome AI Analyzing..."
              : "Analyze $_selectedCrop Leaf with AI",
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    if (_allPredictions.isEmpty) return const SizedBox();

    final topDisease = _predictionResult?["top_disease"] ?? "Unknown Condition";
    final topProb = _predictionResult?["top_probability"] ?? 0;
    final isHealthy = topDisease.toString().toLowerCase().contains("healthy");

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "3. AI DETECTION REPORT",
                style: TextStyle(
                  color: DoctorCropColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DoctorCropColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: DoctorCropColors.primary,
                      size: 11,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Genome Model v2",
                      style: TextStyle(
                        color: DoctorCropColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Detected Condition Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: DoctorCropTheme.cardDecoration(hasShadow: true),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isHealthy
                        ? DoctorCropColors.primaryLight
                        : DoctorCropColors.accentLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isHealthy ? Icons.eco_rounded : Icons.coronavirus_outlined,
                    color: isHealthy
                        ? DoctorCropColors.primary
                        : DoctorCropColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHealthy ? "Crop Status" : "Primary Diagnosis",
                        style: const TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        topDisease,
                        style: const TextStyle(
                          color: DoctorCropColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHealthy
                            ? "Leaf appears healthy with no infection detected"
                            : "Treatment recommended to prevent spread",
                        style: const TextStyle(
                          color: DoctorCropColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$topProb%",
                      style: TextStyle(
                        color: isHealthy
                            ? DoctorCropColors.primary
                            : DoctorCropColors.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      "confidence",
                      style: TextStyle(
                        color: DoctorCropColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // All Probabilities Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All Analyzed Probabilities",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DoctorCropColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._allPredictions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final disease = p["disease"].toString();
                  final probability = (p["probability"] as num).toDouble();
                  final isTop = index == 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isTop
                                    ? DoctorCropColors.primary
                                    : DoctorCropColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: isTop ? Colors.white : DoctorCropColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                disease,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                                  color: isTop
                                      ? DoctorCropColors.textPrimary
                                      : DoctorCropColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              "$probability%",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isTop ? FontWeight.w800 : FontWeight.w500,
                                color: isTop
                                    ? DoctorCropColors.primary
                                    : DoctorCropColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (probability / 100).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: DoctorCropColors.surfaceMuted,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTop
                                  ? DoctorCropColors.primary
                                  : DoctorCropColors.textMuted.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitToAgronomist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorCropColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submit to Local Agronomist",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Forward diagnostic report to regional extension officers in Rwanda.",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Diagnostic report sent to verified regional agronomist!"),
                        backgroundColor: DoctorCropColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_rounded, size: 16),
                  label: const Text("Send to Agronomist"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DoctorCropColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("PDF report downloaded to phone memory"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
