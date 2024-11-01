import 'package:flutter/material.dart';

class DynamicDetailPage extends StatefulWidget {
  const DynamicDetailPage({super.key});

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends State<DynamicDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Text('动态详情页面');
  }
}