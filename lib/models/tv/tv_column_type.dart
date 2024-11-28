import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

List<ListItem> tvColumnTypeConfig = [
  ListItem(
    icon: Icons.pageview,
    label: '找电视剧',
    color: const Color.fromRGBO(33, 170, 230, 1),
    onTap: () => Get.toNamed('/tvSearch?type=tv'),
  ),
  ListItem(
    icon: Icons.live_tv,
    label: 'B站出品',
    color: const Color.fromRGBO(255,103,150, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=61060&title=B站出品'),
  ),
  ListItem(
    icon: Icons.flatware,
    label: '下饭合集',
    color: const Color.fromRGBO(222,135,2, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=20&title=下饭合集'),
  ),
  ListItem(
    icon: FontAwesomeIcons.thumbsUp,
    label: '豆瓣高分',
    color: const Color.fromRGBO(6,194,21, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=71501&title=豆瓣高分'),
  ),
  ListItem(
    icon: FontAwesomeIcons.handSparkles,
    label: '新奇剧场',
    color: const Color.fromRGBO(30,30,30, 1),
    onTap: () => Get.toNamed('/history'),
  ),
  ListItem(
    icon: Icons.south_america,
    label: '经典美剧',
    color: const Color.fromRGBO(210,168,66, 1),
    onTap: () => Get.toNamed('/tvNavhide?id=70314&title=经典美剧'),
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