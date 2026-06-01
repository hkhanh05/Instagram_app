class MetaAiService {
  Future<String> sendChat({
    required List<Map<String, String>> messages,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final lastMessage = messages.last['content']?.toLowerCase().trim() ?? '';

    if (lastMessage.contains('xin chào') ||
        lastMessage.contains('hello') ||
        lastMessage.contains('hi')) {
      return 'Xin chào 👋 Mình là Meta AI phiên bản demo.';
    }

    if (lastMessage.contains('thời tiết')) {
      return 'Hôm nay thời tiết khá đẹp ☀️';
    }

    if (lastMessage.contains('flutter')) {
      return 'Flutter là framework của Google để làm app đa nền tảng.';
    }

    if (lastMessage.contains('firebase')) {
      return 'Firebase hỗ trợ Auth, Firestore, Storage và nhiều dịch vụ khác.';
    }

    if (lastMessage.contains('instagram')) {
      return 'Instagram là mạng xã hội chia sẻ ảnh, video và tin nhắn.';
    }

    if (lastMessage.contains('bạn là ai')) {
      return 'Mình là Meta AI bản demo trong app của bạn 🤖';
    }

    return 'Mình đã nhận được: "${messages.last['content']}"';
  }
}