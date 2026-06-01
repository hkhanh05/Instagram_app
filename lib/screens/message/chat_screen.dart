import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/message/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String opponentUsername;
  final String opponentName;
  final String opponentAvatarUrl;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.opponentUsername,
    required this.opponentName,
    required this.opponentAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  String get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final senderId =
        _currentUserId.isNotEmpty ? _currentUserId : 'unknown_user';

    await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: senderId,
      text: text,
    );

    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF0B0B0B);
    const bodyColor = Color(0xFFF3F1F6);
    const footerColor = Color(0xFF0B0B0B);

    return Scaffold(
      backgroundColor: headerColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(headerColor),
            Expanded(
              child: Container(
                color: bodyColor,
                child: StreamBuilder<List<MessageModel>>(
                  stream: _chatService.streamMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi tải tin nhắn: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messages = snapshot.data!;

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('Chưa có tin nhắn nào'),
                      );
                    }

                    _scrollToBottom();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;

                        return MessageBubble(
                          text: message.text,
                          isMe: isMe,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            _buildFooter(footerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color headerColor) {
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _IconCircleButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          _buildAvatar(widget.opponentAvatarUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.opponentUsername,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.opponentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconCircleButton(
            icon: Icons.call_outlined,
            onPressed: () {},
          ),
          _IconCircleButton(
            icon: Icons.videocam_outlined,
            onPressed: () {},
          ),
          _IconCircleButton(
            icon: Icons.info_outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Color footerColor) {
    return Container(
      color: footerColor,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Row(
        children: [
          _IconCircleButton(
            icon: Icons.emoji_emotions_outlined,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16171C),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nhắn tin...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _canSend ? _sendMessage : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color:
                          _canSend ? const Color(0xFF4C64FF) : Colors.white24,
                    ),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _IconCircleButton(
            icon: Icons.mic_none_rounded,
            onPressed: () {},
          ),
          _IconCircleButton(
            icon: Icons.image_outlined,
            onPressed: () {},
          ),
          _IconCircleButton(
            icon: Icons.add_rounded,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey.shade800,
      );
    }

    return const CircleAvatar(
      radius: 20,
      backgroundColor: Color(0xFF2B2D33),
      child: Icon(
        Icons.person,
        color: Colors.white70,
        size: 22,
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _IconCircleButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 18,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}