import 'package:flutter/material.dart';

class PBadge extends StatelessWidget {
  final String? text;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final String? type;
  final String? size;
  final String? stack;
  final double? fs;
  const PBadge(
      {super.key,
      this.text,
      this.top,
      this.right,
      this.bottom,
      this.left,
      this.type = 'primary',
      this.size = 'medium',
      this.stack = 'position',
      this.fs});

  @override
  Widget build(BuildContext context) {
    ColorScheme t = Theme.of(context).colorScheme;
    // 背景色
    Color bgColor = t.primary;
    // 前景色
    Color color = t.onPrimary;
    // 边框色
    Color borderColor = Colors.transparent;
    if (type == 'owner') {
      bgColor = const Color.fromRGBO(0, 192, 255, 1);
      color = Colors.white;
    }
    if (type == 'vip') {
      bgColor = const Color.fromRGBO(251, 114, 153, 1);
      color = Colors.white;
    }
    if (type == 'gray') {
      bgColor = Colors.black54.withOpacity(0.4);
      color = Colors.white;
    }
    if (type == 'color') {
      bgColor = t.primaryContainer.withOpacity(0.6);
      color = t.primary;
    }
    if (type == 'line') {
      bgColor = Colors.transparent;
      color = t.primary;
      borderColor = t.primary;
    }
    if (type == 'transparent') {
      bgColor = const Color.fromRGBO(57,25,18, 0.2);
      color = Colors.white;
      borderColor = Colors.transparent;
    }

    EdgeInsets paddingStyle =
        const EdgeInsets.symmetric(vertical: 1, horizontal: 6);
    double fontSize = 11;
    BorderRadius br = BorderRadius.circular(4);
    if (size == 'small') {
      paddingStyle = const EdgeInsets.symmetric(vertical: 0, horizontal: 3);
      fontSize = 11;
      br = BorderRadius.circular(3);
    }
    Widget content = Container(
      padding: paddingStyle,
      decoration: BoxDecoration(
        borderRadius: br,
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text!,
        style: TextStyle(fontSize: fs ?? fontSize, color: color),
      ),
    );
    if (stack == 'position') {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: content,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: content,
      );
    }
  }
}
