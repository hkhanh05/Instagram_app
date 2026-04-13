// Followers
import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Followers")),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (_, index) {
          return ListTile(
            leading: const CircleAvatar(),
            title: Text("User $index"),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text("Follow"),
            ),
          );
        },
      ),
    );
  }
}