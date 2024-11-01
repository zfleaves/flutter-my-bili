import 'package:flutter/material.dart';

class MemberArchivePage extends StatefulWidget {
  const MemberArchivePage({super.key});

  @override
  State<MemberArchivePage> createState() => _MemberArchivePageState();
}

class _MemberArchivePageState extends State<MemberArchivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('他的投稿'),
      ),
    );
  }
}