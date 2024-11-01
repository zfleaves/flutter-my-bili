import 'package:bilibili/http/user.dart';
import 'package:bilibili/models/common/theme_type.dart';
import 'package:bilibili/models/user/info.dart';
import 'package:bilibili/models/user/stat.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MineController extends GetxController {
  // 用户信息 头像、昵称、lv
  Rx<UserInfoData> userInfo = UserInfoData().obs;
  // 用户状态 动态、关注、粉丝
  Rx<UserStat> userStat = UserStat().obs;
  RxBool userLogin = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  Box setting = GStrorage.setting;
  Rx<ThemeType> themeType = ThemeType.system.obs;

  @override
  void onInit() {
    super.onInit();
    if (userInfoCache.get('userInfoCache') != null) {
      userInfo.value = userInfoCache.get('userInfoCache');
      userLogin.value = true;
    }

    themeType.value = ThemeType.values[setting.get(SettingBoxKey.themeMode,
        defaultValue: ThemeType.system.code)];
  }

  // 跳转登录
  onLogin() async {
    if (!userLogin.value) {
      Get.toNamed('/loginPage', preventDuplicates: false);
    } else {
      int mid = userInfo.value.mid!;
      String face = userInfo.value.face!;
      Get.toNamed(
        '/member?mid=$mid',
        arguments: {'face': face},
      );
    }
  }

  // 查询个人信息
  Future queryUserInfo() async {
    if (!userLogin.value) {
      return {'status': false};
    }
    var res = await UserHttp.userInfo();
    if (res['status']) {
      if (res['data'].isLogin) {
        userInfo.value = res['data'];
        userInfoCache.put('userInfoCache', res['data']);
        userLogin.value = true;
      } else {
        resetUserInfo();
      }
    }
    await queryUserStatOwner();
    return res;
  }

  Future queryUserStatOwner() async {
    var res = await UserHttp.userStatOwner();
    if (res['status']) {
      userStat.value = res['data'];
    }
    return res;
  }

  Future resetUserInfo() async {
    userInfo.value = UserInfoData();
    userStat.value = UserStat();
    userInfoCache.delete('userInfoCache');
    userLogin.value = false;
  }

  // 更换主题
  onChangeTheme() {
    Brightness currentBrightness =
        MediaQuery.of(Get.context!).platformBrightness;
    ThemeType currentTheme = themeType.value;
    switch (currentTheme) {
      case ThemeType.dark:
        setting.put(SettingBoxKey.themeMode, ThemeType.light.code);
        themeType.value = ThemeType.light;
        break;
      case ThemeType.light:
        setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);
        themeType.value = ThemeType.dark;
        break;
      case ThemeType.system:
        // 判断当前的颜色模式
        if (currentBrightness == Brightness.light) {
          setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);
          themeType.value = ThemeType.dark;
        } else {
          setting.put(SettingBoxKey.themeMode, ThemeType.light.code);
          themeType.value = ThemeType.light;
        }
        break;
    }
    Get.forceAppUpdate();
  }

  // 关注
  pushFollow() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    // 关注页面
    Get.toNamed('/follow?mid=${userInfo.value.mid}', preventDuplicates: false);
  }

  // 粉丝
  pushFans() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/fan?mid=${userInfo.value.mid}', preventDuplicates: false);
  }

  // 动态
  pushDynamic() {
    if (!userLogin.value) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.toNamed('/memberDynamics?mid=${userInfo.value.mid}',
        preventDuplicates: false);
  }
}
