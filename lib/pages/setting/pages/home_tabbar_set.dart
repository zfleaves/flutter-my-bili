import 'package:flutter/material.dart';

class TabbarSetPage extends StatefulWidget {
  const TabbarSetPage({super.key});

  @override
  State<TabbarSetPage> createState() => _TabbarSetPageState();
}

class _TabbarSetPageState extends State<TabbarSetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabbar编辑'),
      ),
    );
  }
}