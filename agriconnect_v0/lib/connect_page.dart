import 'package:agriconnect_v0/notifier.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// Add this import at the top of your file
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> refreshAllData() async {
  final me = sessionNotifier.value;
  if (me == null) return;

  final response = await http.post(
    Uri.parse("http://192.168.50.36:8000/fetch-all"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"phone": me.phoneNumber}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    fetchedUsers.value = (data['users'] as List)
        .map((item) => UserInfo.fromJson(item as Map<String, dynamic>))
        .toList();

    fetchChats.value = (data['chats'] as List)
        .map((chat) => UserChats.fromJson(chat as Map<String, dynamic>))
        .toList();
  }
}

class AgroChatListPage extends StatefulWidget {
  const AgroChatListPage({super.key});

  @override
  State<AgroChatListPage> createState() => _AgroChatListPageState();
}

class _AgroChatListPageState extends State<AgroChatListPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Agronomists", "Shops"];

  // From the full chats list, extract one entry per unique person we talked to.
  // Each entry is the LATEST message with that person.
  List<UserChats> _getUniqueConversations(List<UserChats> allChats) {
    final me = sessionNotifier.value;
    if (me == null) return [];

    final Map<int, UserChats> seen = {};

    for (final chat in allChats) {
      // The "other person" is whoever is NOT me
      final otherPersonId = chat.senderId == me.userId
          ? chat.receiverId
          : chat.senderId;

      // Keep only the latest message per person (list is ordered ASC so last wins)
      seen[otherPersonId] = chat;
    }

    return seen.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: sessionNotifier,
          builder: (context, user, _) {
            if (user == null) return _loginToChatWidget(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategories(),
                const SizedBox(height: 4),
                ValueListenableBuilder(
                  valueListenable: fetchChats,
                  builder: (context, allChats, _) {
                    final conversations = _getUniqueConversations(
                      allChats ?? [],
                    );

                    return Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(5, 18, 16, 24),
                        children: [
                          if (conversations.isEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  PhosphorIcons.paperPlaneTilt(),
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No chats yet",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          else
                            ...conversations.map(
                              (chat) => _buildChatItem(chat),
                            ),

                          conversations.isEmpty
                              ? SizedBox(height: 430)
                              : SizedBox(height: 100),
                          _buildSuggestionsSection(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _loginToChatWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 32,
                color: Colors.greenAccent.shade700,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Join the conversation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Connect with agronomists and agro shops near you.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD0DDD4)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.greenAccent.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
              ),
              child: TextField(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF111111),
                ),
                cursorColor: Colors.greenAccent.shade700,
                decoration: InputDecoration(
                  hintText: "Search agronomists, shops...",
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E0), width: 0.8),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF555555),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 33,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = selectedCategory == item;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.greenAccent.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Colors.greenAccent.shade700
                      : const Color(0xFFE2E2E0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                item,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF444444),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Shows one row per person — the latest message is used as preview
  Widget _buildChatItem(UserChats chat) {
    final me = sessionNotifier.value;
    if (me == null) return const SizedBox();

    final otherPersonId = chat.senderId == me.userId
        ? chat.receiverId
        : chat.senderId;

    // Show sender's name; if I sent it, still show the other person's name
    final String displayName = chat.isMine
        ? chat.receiverName
        : chat.senderName;

    final String lastMessagePreview = chat.isMine
        ? "You: ${chat.message}"
        : chat.message;

    return GestureDetector(
      onTap: () {
        // Filter all messages that belong to this conversation
        final allChats = fetchChats.value ?? [];
        final conversationMessages = allChats
            .where(
              (m) =>
                  (m.senderId == me.userId && m.receiverId == otherPersonId) ||
                  (m.senderId == otherPersonId && m.receiverId == me.userId),
            )
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgroChatConversationPage(
              otherPersonName: displayName,
              otherPersonId: otherPersonId,
              initialMessages: conversationMessages,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(0),
          border: Border(),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 0.5),
              ),
              child: Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMessagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 13,
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
                  _formatTime(chat.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return "$h:$m";
    } else if (diff.inDays < 7) {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return days[time.weekday - 1];
    }
    return "${time.day}/${time.month}";
  }

  Widget _buildSuggestionsSection() {
    return ValueListenableBuilder(
      valueListenable: fetchedUsers,
      builder: (context, users, _) {
        if (users == null || users.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "People to connect with",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Farmers, agronomists & shops near you",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.greenAccent.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...users.map((user) => _buildSuggestionCard(user)),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionCard(UserInfo person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEA), width: 0.9),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade700.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.greenAccent.shade700,
                  size: 22,
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCCCCC),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person.phoneNumber,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: Color(0xFFBBBBBB),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      person.location,
                      style: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgroChatConversationPage(
                    otherPersonName: person.fullName,
                    otherPersonId: person.user_id,
                    initialMessages: const [],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message_outlined, size: 13, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Message",
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Conversation Page
// ─────────────────────────────────────────────────────────

class AgroChatConversationPage extends StatefulWidget {
  final String otherPersonName;
  final int otherPersonId;
  final List<UserChats> initialMessages;

  const AgroChatConversationPage({
    super.key,
    required this.otherPersonName,
    required this.otherPersonId,
    required this.initialMessages,
  });

  @override
  State<AgroChatConversationPage> createState() =>
      _AgroChatConversationPageState();
}

class _AgroChatConversationPageState extends State<AgroChatConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Convert UserChats history into simple maps the bubble widget uses
    _messages = widget.initialMessages.map((m) {
      return <String, dynamic>{
        "text": m.message,
        "isMe": m.isMine,
        "time": _formatTime(m.createdAt),
      };
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Show the message in the UI immediately (optimistic update)
    setState(() {
      _messages.add(<String, dynamic>{
        "text": text,
        "isMe": true,
        "time": _formatTime(DateTime.now()),
      });
    });
    _controller.clear();
    _scrollToBottom();

    // Send to backend
    final me = sessionNotifier.value;
    if (me == null) return;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.50.36:8000/send-message"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_phone": me.phoneNumber,
          "receiver_id": widget.otherPersonId,
          "message": text,
        }),
      );

      final data = jsonDecode(response.body);
      if (data["success"] != true) {
        print("Message failed to save: ${data['message']}");
      }
    } catch (e) {
      print("Send message error: $e");
    }
    await refreshAllData();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        "No messages yet.\nSay hello! 👋",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _buildBubble(_messages[i]),
                    ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0EC))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: const Color(0xFF111111),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade700.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.otherPersonName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.greenAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.otherPersonName,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined, size: 20),
            color: const Color(0xFF555555),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: const Color(0xFF555555),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isMe = msg["isMe"] as bool;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.greenAccent.shade700 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe
              ? null
              : Border.all(color: const Color(0xFFEEEEEA), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg["text"] as String,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              msg["time"] as String,
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFFBBBBBB),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0EC))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            color: const Color(0xFF888888),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF111111)),
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8E8E4),
                    width: 0.8,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8E8E4),
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.greenAccent.shade700,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
