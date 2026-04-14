import 'dart:async';
import 'package:flutter/material.dart';

class StoryViewScreen extends StatefulWidget {
  final int initialUser;

  const StoryViewScreen({super.key, this.initialUser = 0});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  int currentUser = 0;
  int currentStory = 0;

  final List<List<String>> data = [
    // USER 1 (chính bạn)
    [
      'https://picsum.photos/500/800?1',
      'https://picsum.photos/500/800?2',
    ],

    // USER 2
    [
      'https://picsum.photos/500/800?3',
      'https://picsum.photos/500/800?4',
    ],

    // USER 3
    [
      'https://picsum.photos/500/800?5',
      'https://picsum.photos/500/800?6',
    ],
  ];

  double progress = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser;
    start();
  }

  void start() {
    progress = 0;
    timer?.cancel();

    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        progress += 0.01;
        if (progress >= 1) next();
      });
    });
  }

  void next() {
    if (currentStory < data[currentUser].length - 1) {
      currentStory++;
      start();
    } else {
      // qua user tiếp theo
      if (currentUser < data.length - 1) {
        currentUser++;
        currentStory = 0;
        start();
      } else {
        Navigator.pop(context);
      }
    }
  }

  void prev() {
    if (currentStory > 0) {
      currentStory--;
      start();
    } else if (currentUser > 0) {
      currentUser--;
      currentStory = data[currentUser].length - 1;
      start();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = data[currentUser];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final w = MediaQuery.of(context).size.width;
          if (d.globalPosition.dx < w / 2) {
            prev();
          } else {
            next();
          }
        },
        onVerticalDragEnd: (_) => Navigator.pop(context),
        child: Stack(
          children: [
            // IMAGE
            Image.network(
              stories[currentStory],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // PROGRESS
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(stories.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        value: i == currentStory
                            ? progress
                            : (i < currentStory ? 1 : 0),
                        backgroundColor: Colors.white30,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // HEADER + CLOSE
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150'),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "username",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}