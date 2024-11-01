import 'package:flutter/material.dart';

class FollowSearchPage extends StatefulWidget {
  const FollowSearchPage({super.key});

  @override
  State<FollowSearchPage> createState() => _FollowSearchPageState();
}

class _FollowSearchPageState extends State<FollowSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索关注'),
      ),
    );
  }
}