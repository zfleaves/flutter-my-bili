import 'package:flutter/material.dart';

class MessageLikePage extends StatelessWidget {
  const MessageLikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收到的赞'),
      ),
    );
  }
}