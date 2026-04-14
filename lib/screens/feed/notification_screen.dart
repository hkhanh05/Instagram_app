import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150',
              ),
            ),
            title: const Text("username liked your post"),
            subtitle: const Text("2 minutes ago"),
            trailing: Image.network(
              'https://picsum.photos/50',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}