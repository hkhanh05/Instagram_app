import 'package:flutter/material.dart';
import '../../services/meta_ai_service.dart';
import '../../widgets/message/message_bubble.dart';

class MetaAiChatScreen extends StatefulWidget {
  const MetaAiChatScreen({super.key});

  @override
  State<MetaAiChatScreen> createState() => _MetaAiChatScreenState();
}

class _MetaAiChatScreenState extends State<MetaAiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MetaAiService _service = MetaAiService();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Xin chào, mình là Meta AI. Bạn cần mình giúp gì?',
      'isMe': false,
    }
  ];

  bool _isSending = false;

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
      });
      _controller.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final apiMessages = <Map<String, String>>[
        {
          'role': 'system',
          'content':
              'Bạn là trợ lý AI tiếng Việt, trả lời ngắn gọn, tự nhiên và thân thiện.',
        },
        for (final m in _messages)
          {
            'role': m['isMe'] == true ? 'user' : 'assistant',
            'content': m['text'].toString(),
          },
      ];

      final reply = await _service.sendChat(messages: apiMessages);

      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': reply,
          'isMe': false,
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': 'Lỗi: $e',
          'isMe': false,
        });
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Meta AI'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(
                    text: message['text'] as String,
                    isMe: message['isMe'] as bool,
                  );
                },
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Đang phản hồi...',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}