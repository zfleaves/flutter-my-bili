import 'package:flutter/material.dart';

class PlayGesturePage extends StatefulWidget {
  const PlayGesturePage({super.key});

  @override
  State<PlayGesturePage> createState() => _PlayGesturePageState();
}

class _PlayGesturePageState extends State<PlayGesturePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手势设置'),
      ),
    );
  }
}