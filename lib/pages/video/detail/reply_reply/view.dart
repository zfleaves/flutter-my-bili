import 'package:flutter/material.dart';

class VideoReplyReplyPanel extends StatefulWidget {
  const VideoReplyReplyPanel({super.key});

  @override
  State<VideoReplyReplyPanel> createState() => _VideoReplyReplyPanelState();
}

class _VideoReplyReplyPanelState extends State<VideoReplyReplyPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论详情'),
      ),
    );
  }
}