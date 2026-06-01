import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final String avatarUrl;
  final String note;
  final String username;
  final bool isMainUser;
  final bool isOnline;

  const NoteItem({
    super.key,
    required this.avatarUrl,
    required this.note,
    required this.username,
    required this.isMainUser,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final label = isMainUser ? 'Your note' : username;

    return SizedBox(
      width: 86,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF2B2B2B),
                  backgroundImage:
                      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 34,
                        )
                      : null,
                ),
                Positioned(
                  top: -2,
                  child: _NoteBubble(text: note),
                ),
                if (isOnline)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF31D158),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
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
    );
  }
}

class _NoteBubble extends StatelessWidget {
  final String text;

  const _NoteBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3F46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.1,
        ),
      ),
    );
  }
}