import 'package:flutter/material.dart';

class MemberLikePage extends StatefulWidget {
  const MemberLikePage({super.key});

  @override
  State<MemberLikePage> createState() => _MemberLikePageState();
}

class _MemberLikePageState extends State<MemberLikePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户最近喜欢'),
      ),
    );
  }
}
