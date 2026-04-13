import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final String note;
  final String username;

  const NoteItem({
    super.key,
    required this.note,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // ===== NOTE (TRÊN AVATAR) =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ),

          // ===== AVATAR =====
          const CircleAvatar(radius: 25),

          const SizedBox(height: 5),

          // ===== USERNAME (DƯỚI) =====
          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}