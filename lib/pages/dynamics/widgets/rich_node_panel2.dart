import 'package:flutter/material.dart';

InlineSpan richNode2(dynamic item, context) {
  List<InlineSpan> spanChilds = [];
  spanChilds.add(
    TextSpan(
      text: '我是测试数据奥;啊啊' + '\n',
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
    ),
  );
  return TextSpan(
    children: spanChilds,
  );
}