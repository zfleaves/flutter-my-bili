import 'package:flutter/material.dart';


class MemberSeasonsPage extends StatefulWidget {
  const MemberSeasonsPage({super.key});

  @override
  State<MemberSeasonsPage> createState() => _MemberSeasonsPageState();
}

class _MemberSeasonsPageState extends State<MemberSeasonsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户专栏'),
      ),
    );
  }
}