import 'package:flutter/material.dart';

class MemberCoinPage extends StatefulWidget {
  const MemberCoinPage({super.key});

  @override
  State<MemberCoinPage> createState() => _MemberCoinPageState();
}

class _MemberCoinPageState extends State<MemberCoinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户最近投币'),
      ),
    );
  }
}
