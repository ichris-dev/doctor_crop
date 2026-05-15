// ignore_for_file: deprecated_member_use, unnecessary_underscores, avoid_print

import 'dart:convert';
import 'dart:io';
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
  // ── Design tokens ──────────────────────────────────────────────────────
  static const Color _ink = Color(0xFF111111);
  static const Color _surface = Color(0xFFFAFAF8);
  static const Color _border = Color(0xFFEEEEEA);
  static const Color _green = Color(0xFF40B37A);
  static const Color _greenDark = Color(0xFF2A7D55);
  static const Color _orange = Color(0xFFF97316);
  static const Color _orangeLight = Color(0xFFFB923C);

  // ── State ──────────────────────────────────────────────────────────────
  String? _selectedCrop;
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

  bool _isAnalyzing = false;
  int _analyzeStep = 0;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _crops = [
    {'name': 'Potato', 'icon': Icons.eco_outlined, 'color': Color(0xFF2A7D55)},
    {
      'name': 'Maize',
      'icon': Icons.agriculture_outlined,
      'color': Color(0xFFF97316),
    },
    {'name': 'Beans', 'icon': Icons.spa_outlined, 'color': Color(0xFF6ECF9B)},
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
      print("No image or crop selected");
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

      print("STATUS: ${response.statusCode}");
      print("BODY: $responseBody");

      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 && decoded["prediction"] != null) {
        final prediction = decoded["prediction"];

        setState(() {
          _predictionResult = prediction;
          _allPredictions = prediction["all_probabilities"] ?? [];
          _resultReady = true;
          _isUploading = false;
        });
      } else {
        setState(() {
          _uploadError = decoded.toString();
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = e.toString();
        _isUploading = false;
      });

      print("Upload error: $e");
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
        _analyzeStep = 0;
        _fadeController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          children: [
            _buildIntroSection(),
            _buildCropSelector(),
            _buildCameraSection(),

            if (_resultReady) _buildPredictionResults(),

            if (_capturedImage != null && !_resultReady) _buildAnalyzeButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    if (_allPredictions.isEmpty) return const SizedBox();

    final topDisease = _predictionResult?["top_disease"] ?? "";
    final topProb = _predictionResult?["top_probability"] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label ──────────────────────────────────────────
          Row(
            children: [
              const Text(
                "DETECTION RESULTS",
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, color: _green, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      "Genome Models",
                      style: TextStyle(
                        color: _green,
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

          // ── Top result highlight card ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.coronavirus_outlined,
                    color: _orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Most likely disease",
                        style: TextStyle(color: Colors.black38, fontSize: 10.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topDisease,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
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
                        color: _orange,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      "confidence",
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── All probabilities list ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEA), width: 0.9),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          "Disease name",
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "Probability",
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(height: 0.8, color: const Color(0xFFEEEEEA)),

                // Each prediction row
                ..._allPredictions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final disease = p["disease"].toString();
                  final probability = (p["probability"] as num).toDouble();
                  final isTop = index == 0;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Rank badge
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isTop
                                        ? _orange.withOpacity(0.12)
                                        : const Color(0xFFEEEEEA),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: isTop
                                          ? _orange
                                          : const Color(0xFFAAAAAA),
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
                                      color: isTop
                                          ? const Color(0xFF111111)
                                          : const Color(0xFF777777),
                                      fontSize: 12.5,
                                      fontWeight: isTop
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "$probability%",
                                  style: TextStyle(
                                    color: isTop
                                        ? _orange
                                        : const Color(0xFFAAAAAA),
                                    fontSize: 13,
                                    fontWeight: isTop
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: probability / 100,
                                minHeight: 5,
                                backgroundColor: const Color(0xFFEEEEEA),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isTop ? _orange : const Color(0xFFCCCCCC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (index < _allPredictions.length - 1)
                        Container(
                          height: 0.8,
                          color: const Color(0xFFEEEEEA),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Intro ──────────────────────────────────────────────────────────────
  Widget _buildIntroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: _green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How it works",
                    style: TextStyle(
                      color: _ink,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Select your crop, capture a clear photo of the affected leaf, then let Genome AI detect the disease and generate a report.",
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool cassavaIsFilled = false;
  bool potatoIsFilled = false;
  bool maizeIsFilled = false;
  bool beansIsFilled = false;
  bool tomatoIsFilled = false;

  // ── Crop selector ──────────────────────────────────────────────────────
  Widget _buildCropSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Text(
            "SELECT CROP",
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 82,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 80),
              scrollDirection: Axis.horizontal,
              itemCount: _crops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final crop = _crops[i];
                final selected = _selectedCrop == crop['name'];
                final color = crop['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCrop = crop['name'];

                    _resultReady = false;
                    _isAnalyzing = false;
                    _analyzeStep = 0;
                    _fadeController.reset();
                  }),

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 76,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.10) : _surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? color : _border,
                        width: selected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          crop['icon'] as IconData,
                          color: selected ? color : const Color(0xFFAAAAAA),
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          crop['name'] as String,
                          style: TextStyle(
                            color: selected ? color : const Color(0xFF777777),
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Camera section ─────────────────────────────────────────────────────
  Widget _buildCameraSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "CAPTURE LEAF IMAGE",
              style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: _selectedCrop == null ? null : _showImageSourceSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _capturedImage != null ? Colors.black : _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _capturedImage != null
                      ? Colors.transparent
                      : _selectedCrop != null
                      ? _green.withOpacity(0.40)
                      : _border,
                  width: _selectedCrop != null && _capturedImage == null
                      ? 1.5
                      : 0.8,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _capturedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_capturedImage!, fit: BoxFit.cover),

                        // Remove image button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _cropImages[_selectedCrop!] = null;
                                _resultReady = false;
                                _isAnalyzing = false;
                                _analyzeStep = 0;
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

                        // Retake button
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Retake",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                            opacity: _selectedCrop != null
                                ? 0.5 + (_pulseController.value * 0.5)
                                : 0.3,
                            child: child,
                          ),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _selectedCrop != null
                                  ? _green.withOpacity(0.10)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 28,
                              color: _selectedCrop != null
                                  ? _green
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _selectedCrop != null
                              ? "Tap to capture $_selectedCrop leaf"
                              : "Select a crop first",
                          style: TextStyle(
                            color: _selectedCrop != null
                                ? _ink
                                : Colors.grey.shade400,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedCrop != null
                              ? "Make sure the leaf fills the frame clearly"
                              : "Choose from the crop list above",
                          style: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 12,
                          ),
                        ),
                        if (_selectedCrop != null) ...[
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _captureChip(
                                Icons.camera_alt_outlined,
                                "Camera",
                                _green,
                                () => _captureImage(ImageSource.camera),
                              ),
                              const SizedBox(width: 10),
                              _captureChip(
                                Icons.photo_library_outlined,
                                "Gallery",
                                _orange,
                                () => _captureImage(ImageSource.gallery),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          if (_selectedCrop != null && _capturedImage == null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _captureTip(Icons.wb_sunny_outlined, "Good lighting"),
                const SizedBox(width: 8),
                _captureTip(
                  Icons.center_focus_strong_outlined,
                  "Leaf in focus",
                ),
                const SizedBox(width: 8),
                _captureTip(
                  Icons.photo_size_select_large_outlined,
                  "Fill frame",
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _captureChip(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _captureTip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _green.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: _green),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _greenDark,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Capture leaf image",
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Ensure good lighting and the leaf fills the frame",
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
              ),
              const SizedBox(height: 20),
              _sheetOption(
                icon: Icons.camera_alt_outlined,
                label: "Take a photo",
                sub: "Use your rear camera for best results",
                color: _green,
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _sheetOption(
                icon: Icons.photo_library_outlined,
                label: "Choose from gallery",
                sub: "Pick an existing leaf photo",
                color: _orange,
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: color.withOpacity(0.40),
            ),
          ],
        ),
      ),
    );
  }

  // ── Analyze button ─────────────────────────────────────────────────────
  Widget _buildAnalyzeButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: _isUploading
            ? null
            : () async {
                await sendImageData();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: _isUploading ? Colors.grey.shade400 : _green,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: _isUploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Analyse Image",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Analyzing indicator ────────────────────────────────────────────────
  Widget _buildAnalyzingIndicator() {
    final steps = [
      'Preprocessing image...',
      'Extracting leaf features...',
      'Running Genome AI model...',
      'Generating report...',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Opacity(
                    opacity: 0.4 + (_pulseController.value * 0.6),
                    child: child,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Genome AI is analyzing...",
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (i) {
              final done = _analyzeStep > i;
              final active = _analyzeStep == i + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: done
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: _green,
                              size: 18,
                            )
                          : active
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _orange,
                            )
                          : Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      steps[i],
                      style: TextStyle(
                        color: done
                            ? _green
                            : active
                            ? _ink
                            : Colors.grey.shade400,
                        fontSize: 12.5,
                        fontWeight: done || active
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tipCard(Map<String, dynamic> tip) {
    final color = tip['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'] as String,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['body'] as String,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit to agronomist ───────────────────────────────────────────────
  Widget _buildSubmitToAgronomist() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
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
                      color: _orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.send_outlined,
                      color: _orange,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Submit to Agronomist",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Send report for professional review",
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Send to Agronomist",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: _orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.download_outlined,
                        color: _orange,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
