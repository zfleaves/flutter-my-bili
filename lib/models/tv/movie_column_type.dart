import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

List<ListItem> movieColumnTypeConfig = [
  ListItem(
    icon: Icons.pageview,
    label: '找电影',
    color: Colors.red,
    onTap: () => Get.toNamed('/tvSearch?type=movie'),
  ),
  ListItem(
    icon: Icons.live_tv,
    label: 'B站出品',
    color: const Color.fromRGBO(255,103,150, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=61060&title=B站出品'),
  ),
  ListItem(
    icon: Icons.schedule,
    label: '即将上线',
    color: const Color.fromRGBO(33, 170, 230, 1),
    onTap: () => Get.toNamed('/movieLine'),
  ),
  ListItem(
    icon: Icons.flatware,
    label: '罗温·艾金森',
    color: const Color.fromRGBO(222,135,2, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=74243&title=罗温·艾金森'),
  ),
  ListItem(
    icon: FontAwesomeIcons.thumbsUp,
    label: '跟我学沪语',
    color: const Color.fromRGBO(6,194,21, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=74250&title=跟我学沪语'),
  ),
  ListItem(
    icon: Icons.south_america,
    label: '动画巡游',
    color: const Color.fromRGBO(210,168,66, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=72708&title=世界动画巡游'),
  ),
];

class ListItem {
  // ignore: prefer_typing_uninitialized_variables
  final icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
 
  ListItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}