// Following
import 'package:flutter/material.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (_, index) {
          return ListTile(
            leading: const CircleAvatar(),
            title: Text("User $index"),
            subtitle: const Text("Following"),
            trailing: OutlinedButton(
              onPressed: () {},
              child: const Text("Unfollow"),
            ),
          );
        },
      ),
    );
  }
}