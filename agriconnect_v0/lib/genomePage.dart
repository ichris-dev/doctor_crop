// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _kWsUrl = "ws://192.168.50.36:8000/chat";

class GenomeAIPage extends StatefulWidget {
  const GenomeAIPage({super.key});

  @override
  State<GenomeAIPage> createState() => _GenomeAIPageState();
}

class _GenomeAIPageState extends State<GenomeAIPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<Map<String, String>> _messages = [];
  String _streamBuffer = "";
  bool _isLoading = false;

  late WebSocketChannel _channel;

  final List<Map<String, dynamic>> _suggestions = [
    {
      "icon": Icons.coronavirus_outlined,
      "color": DoctorCropColors.accent,
      "text": "How do I identify and treat Cassava Brown Streak Disease?",
    },
    {
      "icon": Icons.wb_sunny_outlined,
      "color": DoctorCropColors.accentDark,
      "text": "What crops are most suitable for planting during Season B?",
    },
    {
      "icon": Icons.bug_report_outlined,
      "color": DoctorCropColors.primary,
      "text": "How can I control aphids and whiteflies on my tomatoes?",
    },
    {
      "icon": Icons.science_outlined,
      "color": DoctorCropColors.info,
      "text": "What fertilizer ratio is recommended for Irish Potato farming?",
    },
  ];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_kWsUrl));
      _channel.stream.listen(
        _onData,
        onError: (_) => _onConnectionError(),
        onDone: () => _reconnect(),
      );
    } catch (_) {}
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _connect();
    });
  }

  void _onConnectionError() {
    if (!_isLoading) return;
    setState(() {
      _messages.add({
        "role": "assistant",
        "text":
            "⚠️ Genome AI service connection is momentarily unavailable. Reconnecting to local agricultural node...",
      });
      _streamBuffer = "";
      _isLoading = false;
    });
  }

  void _onData(dynamic data) {
    final text = data as String;

    if (text == "[DONE]") {
      setState(() {
        if (_streamBuffer.isNotEmpty) {
          _messages.add({"role": "assistant", "text": _streamBuffer});
        }
        _streamBuffer = "";
        _isLoading = false;
      });
    } else {
      setState(() => _streamBuffer += text);
    }
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _messages.add({"role": "user", "text": trimmed});
      _isLoading = true;
      _streamBuffer = "";
    });
    _controller.clear();
    _scrollToBottom();

    final payload = jsonEncode(
      _messages.map((m) => {"role": m["role"], "content": m["text"]}).toList(),
    );
    try {
      _channel.sink.add(payload);
    } catch (e) {
      _onConnectionError();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    try {
      _channel.sink.close();
    } catch (_) {}
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showStreaming = _isLoading && _streamBuffer.isNotEmpty;
    final bool showDots = _isLoading && _streamBuffer.isEmpty;
    final int itemCount =
        _messages.length + (showStreaming ? 1 : 0) + (showDots ? 1 : 0);

    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      itemCount: itemCount,
                      itemBuilder: (ctx, i) {
                        if (i < _messages.length)
                          return _buildBubble(_messages[i]);
                        if (showStreaming)
                          return _buildBubble({
                            "role": "assistant",
                            "text": _streamBuffer,
                          });
                        return _buildTypingIndicator();
                      },
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: DoctorCropColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DoctorCropColors.border, width: 0.8),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: DoctorCropColors.textPrimary,
          size: 16,
        ),
      ),
    ),
    title: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: DoctorCropColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: DoctorCropColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Genome AI Assistant",
              style: TextStyle(
                color: DoctorCropColors.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              "Specialized in Rwandan Agriculture",
              style: TextStyle(
                color: DoctorCropColors.primary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
    actions: [
      if (_messages.isNotEmpty)
        IconButton(
          tooltip: "New Chat",
          onPressed: () => setState(() {
            _messages.clear();
            _streamBuffer = "";
          }),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DoctorCropColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DoctorCropColors.border, width: 0.8),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: DoctorCropColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      const SizedBox(width: 8),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 0.9, color: DoctorCropColors.border),
    ),
  );

  Widget _buildEmptyState() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
    children: [
      Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: DoctorCropColors.primaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DoctorCropColors.primary.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: DoctorCropColors.primary,
            size: 32,
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Center(
        child: Text(
          "Doctor Crop Genome AI",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: DoctorCropColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Center(
        child: Text(
          "Ask questions about Rwandan crop varieties, soil care,\ndisease remedies, and local market trends.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: DoctorCropColors.textSecondary,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
      ),
      const SizedBox(height: 28),
      const Text(
        "RECOMMENDED TOPICS",
        style: TextStyle(
          color: DoctorCropColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 10),
      ..._suggestions.map(
        (s) => GestureDetector(
          onTap: () => _sendMessage(s["text"] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: DoctorCropTheme.cardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (s["color"] as Color).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    s["icon"] as IconData,
                    color: s["color"] as Color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s["text"] as String,
                    style: const TextStyle(
                      color: DoctorCropColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: DoctorCropColors.textMuted,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildBubble(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: DoctorCropColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: DoctorCropColors.primary,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? DoctorCropColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: DoctorCropColors.border, width: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.025),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                msg["text"] ?? "",
                style: TextStyle(
                  color: isUser ? Colors.white : DoctorCropColors.textPrimary,
                  fontSize: 13.5,
                  height: 1.48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: DoctorCropColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: DoctorCropColors.primary,
            size: 16,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DoctorCropColors.border, width: 0.9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: Duration(milliseconds: 500 + i * 160),
                curve: Curves.easeInOut,
                builder: (_, v, __) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: DoctorCropColors.primary.withOpacity(v),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildInputBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border(
        top: BorderSide(color: DoctorCropColors.border, width: 0.9),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: DoctorCropColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DoctorCropColors.border, width: 0.8),
            ),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 13.5,
                color: DoctorCropColors.textPrimary,
                height: 1.4,
              ),
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: "Ask Genome AI anything...",
                hintStyle: TextStyle(
                  color: DoctorCropColors.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _sendMessage(_controller.text),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _isLoading
                  ? DoctorCropColors.border
                  : DoctorCropColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ],
    ),
  );
}
