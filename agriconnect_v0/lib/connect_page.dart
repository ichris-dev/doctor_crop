import 'package:agriconnect_v0/loginpage.dart';
import 'package:agriconnect_v0/notifier.dart';
import 'package:agriconnect_v0/registerPage.dart';
import 'package:agriconnect_v0/theme/app_theme.dart';
import 'package:agriconnect_v0/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> refreshAllData() async {
  final me = sessionNotifier.value;
  if (me == null) return;

  try {
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
  } catch (_) {}
}

class AgroChatListPage extends StatefulWidget {
  const AgroChatListPage({super.key});

  @override
  State<AgroChatListPage> createState() => _AgroChatListPageState();
}

class _AgroChatListPageState extends State<AgroChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = "All";
  String searchQuery = "";
  final List<String> categories = ["All", "Agronomists", "Shops"];

  List<UserChats> _getUniqueConversations(List<UserChats> allChats) {
    final me = sessionNotifier.value;
    if (me == null) return [];

    final Map<int, UserChats> seen = {};

    for (final chat in allChats) {
      final otherPersonId =
          chat.senderId == me.userId ? chat.receiverId : chat.senderId;

      seen[otherPersonId] = chat;
    }

    return seen.values.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorCropColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<SessionUser?>(
          valueListenable: sessionNotifier,
          builder: (context, user, _) {
            if (user == null) return _loginToChatWidget(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategories(),
                const SizedBox(height: 6),
                ValueListenableBuilder<List<UserChats>>(
                  valueListenable: fetchChats,
                  builder: (context, allChats, _) {
                    final rawConversations =
                        _getUniqueConversations(allChats);

                    final conversations = rawConversations.where((c) {
                      final name = c.isMine ? c.receiverName : c.senderName;
                      return searchQuery.isEmpty ||
                          name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          c.message.toLowerCase().contains(searchQuery.toLowerCase());
                    }).toList();

                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: refreshAllData,
                        color: DoctorCropColors.primary,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                          children: [
                            if (conversations.isEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                padding: const EdgeInsets.all(24),
                                decoration: DoctorCropTheme.cardDecoration(),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: DoctorCropColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.forum_outlined,
                                        size: 28,
                                        color: DoctorCropColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      "No conversations yet",
                                      style: TextStyle(
                                        color: DoctorCropColors.textPrimary,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Connect with nearby agronomists and verified shops below to ask questions and buy supplies.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: DoctorCropColors.textSecondary,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "RECENT CONVERSATIONS",
                                  style: TextStyle(
                                    color: DoctorCropColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              ...conversations.map(
                                (chat) => _buildChatItem(chat),
                              ),
                            ],

                            const SizedBox(height: 20),
                            _buildSuggestionsSection(),
                          ],
                        ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: DoctorCropTheme.cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  size: 36,
                  color: DoctorCropColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Farmer & Expert Community",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DoctorCropColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to chat with regional agronomists, consult about crop health, and order supplies directly from local agro stores.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: DoctorCropColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LoginPage(homePage: const WidgetTree()),
                          ),
                        );
                      },
                      child: const Text("Sign In"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterPage(homePage: const WidgetTree()),
                          ),
                        );
                      },
                      child: const Text("Register"),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DoctorCropColors.border, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => searchQuery = val.trim()),
          style: const TextStyle(
            fontSize: 13.5,
            color: DoctorCropColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: "Search conversations, agronomists, shops...",
            hintStyle: const TextStyle(
              color: DoctorCropColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: DoctorCropColors.textMuted,
              size: 20,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: DoctorCropColors.textMuted,
                    onPressed: () {
                      setState(() {
                        searchQuery = "";
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(top: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? DoctorCropColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? DoctorCropColors.primary
                      : DoctorCropColors.border,
                  width: 0.9,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                item,
                style: TextStyle(
                  color: selected ? Colors.white : DoctorCropColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(UserChats chat) {
    final me = sessionNotifier.value;
    if (me == null) return const SizedBox();

    final otherPersonId =
        chat.senderId == me.userId ? chat.receiverId : chat.senderId;

    final String displayName =
        chat.isMine ? chat.receiverName : chat.senderName;

    final String lastMessagePreview =
        chat.isMine ? "You: ${chat.message}" : chat.message;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: DoctorCropTheme.cardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final allChats = fetchChats.value;
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                  style: const TextStyle(
                    color: DoctorCropColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DoctorCropColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(chat.createdAt),
                          style: const TextStyle(
                            color: DoctorCropColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessagePreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DoctorCropColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return ValueListenableBuilder<List<UserInfo>?>(
      valueListenable: fetchedUsers,
      builder: (context, users, _) {
        if (users == null || users.isEmpty) return const SizedBox();

        final filteredUsers = users.where((u) {
          return searchQuery.isEmpty ||
              u.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              u.location.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CONNECT WITH LOCAL EXPERTS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DoctorCropColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Verified agronomists & registered stores in Rwanda",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: DoctorCropColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${filteredUsers.length} available",
                  style: const TextStyle(
                    fontSize: 11,
                    color: DoctorCropColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filteredUsers.map((user) => _buildSuggestionCard(user)),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionCard(UserInfo person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: DoctorCropTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DoctorCropColors.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              person.fullName.isNotEmpty ? person.fullName[0].toUpperCase() : "A",
              style: const TextStyle(
                color: DoctorCropColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        person.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DoctorCropColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: DoctorCropColors.primary,
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: DoctorCropColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        person.location.isNotEmpty ? person.location : "Rwanda",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DoctorCropColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
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
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
            label: const Text("Message"),
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorCropColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  AgroChat Conversation Page
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

    setState(() {
      _messages.add(<String, dynamic>{
        "text": text,
        "isMe": true,
        "time": _formatTime(DateTime.now()),
      });
    });
    _controller.clear();
    _scrollToBottom();

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
      backgroundColor: DoctorCropColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              size: 16,
              color: DoctorCropColors.textPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DoctorCropColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.otherPersonName.isNotEmpty
                      ? widget.otherPersonName[0].toUpperCase()
                      : "A",
                  style: const TextStyle(
                    color: DoctorCropColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherPersonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DoctorCropColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    "Doctor Crop Verified Expert",
                    style: TextStyle(
                      color: DoctorCropColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Voice consultation line is available during farm hours"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.phone_outlined,
              color: DoctorCropColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.9, color: DoctorCropColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: DoctorCropColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: DoctorCropColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Say hello to ${widget.otherPersonName} 👋",
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: DoctorCropColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Ask questions about crop diseases, dosage, or order delivery.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: DoctorCropColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
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

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isMe = msg["isMe"] as bool;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? DoctorCropColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 16),
          ),
          border: isMe
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
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg["text"] as String,
              style: TextStyle(
                color: isMe ? Colors.white : DoctorCropColors.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg["time"] as String,
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : DoctorCropColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Attach photo or scan report"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 22,
                color: DoctorCropColors.textSecondary,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: DoctorCropColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DoctorCropColors.border, width: 0.8),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: DoctorCropColors.textPrimary,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Type agricultural inquiry...",
                    hintStyle: TextStyle(
                      color: DoctorCropColors.textMuted,
                      fontSize: 13,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DoctorCropColors.primary,
                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
