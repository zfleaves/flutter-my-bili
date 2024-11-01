import 'package:flutter/material.dart';

class ActionMenuSetPage extends StatefulWidget {
  const ActionMenuSetPage({super.key});

  @override
  State<ActionMenuSetPage> createState() => _ActionMenuSetPageState();
}

class _ActionMenuSetPageState extends State<ActionMenuSetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频操作菜单'),
      ),
    );
  }
}