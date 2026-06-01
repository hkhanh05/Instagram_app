import 'package:flutter/material.dart';

class PendingMessagesScreen extends StatelessWidget {
  const PendingMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 140, 140),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 140, 140, 140),
        foregroundColor: Colors.white,
        title: const Text('Tin nhắn chờ'),
      ),
      body: const Center(
        child: Text(
          'Pending messages page',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}