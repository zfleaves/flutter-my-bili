import 'package:flutter/material.dart';


class NavigationBarSetPage extends StatefulWidget {
  const NavigationBarSetPage({super.key});

  @override
  State<NavigationBarSetPage> createState() => _NavigationBarSetPageState();
}

class _NavigationBarSetPageState extends State<NavigationBarSetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navbar编辑'),
      ),
    );
  }
}