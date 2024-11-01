import 'dart:async';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:gt3_flutter_plugin/gt3_flutter_plugin.dart';

class LoginPageController extends GetxController {
  final GlobalKey mobFormKey = GlobalKey<FormState>();
  final GlobalKey passwordFormKey = GlobalKey<FormState>();
  final GlobalKey msgCodeFormKey = GlobalKey<FormState>();

  final TextEditingController mobTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController msgCodeTextController = TextEditingController();

  final FocusNode mobTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode msgCodeTextFieldNode = FocusNode();

  final PageController pageViewController = PageController();

  RxInt currentIndex = 0.obs;

  final Gt3FlutterPlugin captcha = Gt3FlutterPlugin();

  // 倒计时60s
  RxInt seconds = 60.obs;
  Timer? timer;
  RxBool smsCodeSendStatus = false.obs;

  // 默认密码登录
  RxInt loginType = 0.obs;

  late String captchaKey;

  late int tel;
  late int webSmsCode;

  RxInt validSeconds = 180.obs;
  Timer? validTimer;
  late String qrcodeKey;

  // 监听pageView切换
  void onPageChange(int index) {
    currentIndex.value = index;
  }

  // 输入手机号 下一页
  void previousPage() async {
    passwordTextFieldNode.unfocus();
    await Future.delayed(const Duration(milliseconds: 200));
    pageViewController.animateToPage(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}