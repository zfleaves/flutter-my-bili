import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final void Function() ? cb;
  final double height;

  const CustomButton({super.key, this.color = Colors.black, this.text = '按钮', this.cb, this.height = 50});

  @override
  Widget build(BuildContext context) {
    TextStyle? titleMedium = Theme.of(context).textTheme.titleMedium;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: cb,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(10),
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child:  Text(
            text, 
            style: TextStyle(
              color: Colors.white,
              fontSize: titleMedium?.fontSize,
              letterSpacing: 2
            ),
          ),
        ),
      ),
    );
  }
}