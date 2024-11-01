import 'package:flutter/material.dart';

class MessageReplyPage extends StatefulWidget {
  const MessageReplyPage({super.key});

  @override
  State<MessageReplyPage> createState() => _MessageReplyPageState();
}

class _MessageReplyPageState extends State<MessageReplyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('回复我的'),
      ),
    );
  }
}