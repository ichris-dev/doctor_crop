// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _kWsUrl = "ws://192.168.50.36:8000/chat";

class GenomeAIPage extends StatefulWidget {
  const GenomeAIPage({super.key});

  @override
  State<GenomeAIPage> createState() => _GenomeAIPageState();
}

class _GenomeAIPageState extends State<GenomeAIPage> {
  static const Color _ink = Color(0xFF111111);
  static const Color _surface = Color(0xFFF5F5F3);
  static const Color _border = Color(0xFFEEEEEA);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<Map<String, String>> _messages = [];
  String _streamBuffer = "";
  bool _isLoading = false;

  late WebSocketChannel _channel;

  final List<Map<String, dynamic>> _suggestions = [
    {
      "icon": Icons.coronavirus_outlined,
      "color": Color(0xFFEA580C),
      "text": "How do I treat cassava brown streak disease?",
    },
    {
      "icon": Icons.wb_sunny_outlined,
      "color": Color(0xFFF97316),
      "text": "What crops should I plant in the rainy season?",
    },
    {
      "icon": Icons.bug_report_outlined,
      "color": Color(0xFF40B37A),
      "text": "How do I control aphids on my tomatoes?",
    },
    {
      "icon": Icons.science_outlined,
      "color": Color(0xFF2563EB),
      "text": "What fertilizer is best for potato farming?",
    },
  ];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  // ── WebSocket lifecycle ──────────────────────────────────────────────
  void _connect() {
    _channel = WebSocketChannel.connect(Uri.parse(_kWsUrl));
    _channel.stream.listen(
      _onData,
      onError: (_) => _onConnectionError(),
      onDone: () => _reconnect(),
    );
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 2), _connect);
  }

  void _onConnectionError() {
    if (!_isLoading) return;
    setState(() {
      _messages.add({
        "role": "assistant",
        "text":
            "⚠️ Lost connection. Make sure the server is running on $_kWsUrl",
      });
      _streamBuffer = "";
      _isLoading = false;
    });
  }

  void _onData(dynamic data) {
    final text = data as String;

    if (text == "[DONE]") {
      // Commit streamed reply to history
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

  // ── Send ─────────────────────────────────────────────────────────────
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

    // Send full conversation history as JSON array
    final payload = jsonEncode(
      _messages.map((m) => {"role": m["role"], "content": m["text"]}).toList(),
    );
    _channel.sink.add(payload);
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
    _channel.sink.close();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool showStreaming = _isLoading && _streamBuffer.isNotEmpty;
    final bool showDots = _isLoading && _streamBuffer.isEmpty;
    final int itemCount =
        _messages.length + (showStreaming ? 1 : 0) + (showDots ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  // ── AppBar ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border, width: 0.8),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.orange,
          size: 16,
        ),
      ),
    ),
    actions: [
      if (_messages.isNotEmpty)
        _appBarBtn(
          "Clear",
          onTap: () => setState(() {
            _messages.clear();
            _streamBuffer = "";
          }),
        ),
      _appBarBtn(
        "New chat",
        icon: Icons.add,
        onTap: () => setState(() {
          _messages.clear();
          _streamBuffer = "";
        }),
      ),
      _appBarIcon(Icons.history),
      _appBarIcon(Icons.more_vert),
    ],
  );

  Widget _appBarBtn(
    String label, {
    IconData? icon,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 5)],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _appBarIcon(IconData icon) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border, width: 0.8),
    ),
    child: Icon(icon, size: 18),
  );

  // ── Empty state ──────────────────────────────────────────────────────
  Widget _buildEmptyState() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
    children: [
      const Center(
        child: Text(
          "Genome AI",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Center(
        child: Text(
          "Ask me anything about crops, diseases,\nfarming tips, or market advice.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13, height: 1.5),
        ),
      ),
      const SizedBox(height: 32),
      const Text(
        "Try asking",
        style: TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 12),
      ..._suggestions.map(
        (s) => GestureDetector(
          onTap: () => _sendMessage(s["text"] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (s["color"] as Color).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    s["icon"] as IconData,
                    color: s["color"] as Color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s["text"] as String,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  // ── Bubble ───────────────────────────────────────────────────────────
  Widget _buildBubble(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isUser ? 14 : 3,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.black54 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                msg["text"] ?? "",
                style: TextStyle(
                  color: isUser ? Colors.white : _ink,
                  fontSize: 13.5,
                  height: 1.52,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Typing dots ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.2, end: 0.8),
                duration: Duration(milliseconds: 500 + i * 160),
                curve: Curves.easeInOut,
                builder: (_, v, __) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(v),
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

  // ── Input bar ────────────────────────────────────────────────────────
  Widget _buildInputBar() => Padding(
    padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border, width: 0.9),
            ),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(fontSize: 13.5, color: _ink, height: 1.4),
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: "Ask Genome AI anything...",
                hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                border: InputBorder.none,
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
              color: _isLoading ? const Color(0xFFCCCCCC) : Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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
