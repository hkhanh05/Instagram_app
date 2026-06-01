import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class HighlightViewerScreen extends StatefulWidget {
  final String imagePath;
  final String title;

  const HighlightViewerScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  State<HighlightViewerScreen> createState() =>
      _HighlightViewerScreenState();
}

class _HighlightViewerScreenState
    extends State<HighlightViewerScreen> {

  double progress = 0;
  Timer? timer;

  @override
void initState() {
  super.initState();

  timer = Timer.periodic(
    const Duration(milliseconds: 50),
    (timer) {
      if (!mounted) return;

      setState(() {
        progress += 0.01;
      });

      if (progress >= 1) {
        timer.cancel();

        setState(() {
          progress = 1;
        });
      }
    },
  );
}

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (_) {
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}