import 'package:bilibili/pages/login/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());

  @override
  void dispose() {
    _loginPageCtr.timer?.cancel();
    _loginPageCtr.validTimer?.cancel();
    // 通常情况下，建议在调用 super.dispose() 之前处理所有自定义的清理逻辑（如取消计时器、关闭网络连接等）。
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Obx(() => _loginPageCtr.currentIndex.value == 0
            ? IconButton(
                onPressed: () async {
                  _loginPageCtr.mobTextFieldNode.unfocus();
                  await Future.delayed(const Duration(milliseconds: 200));
                  Get.back();
                },
                icon: const Icon(Icons.close_outlined))
            : IconButton(
                onPressed: () => _loginPageCtr.previousPage(),
                icon: const Icon(Icons.arrow_back))),
        actions: [
          IconButton(
            tooltip: '浏览器打开',
            onPressed: () {
              Get.offNamed(
                '/webview',
                parameters: {
                  'url': 'https://passport.bilibili.com/h5-app/passport/login',
                  'type': 'login',
                  'pageTitle': '登录bilibili',
                }
              );
            }, 
            icon: const Icon(Icons.language, size: 20),
          ),
          IconButton(
            tooltip: '二维码登录',
            onPressed: () {
              
            }, 
            icon: const Icon(Icons.qr_code, size: 20)
          ),
          const SizedBox(width: 22),
        ],
        title: const Text('登录页面'),
      ),
    );
  }
}
