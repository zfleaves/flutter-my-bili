import 'dart:io';

import 'package:bilibili/common/widgets/custom_toast.dart';
import 'package:bilibili/pages/main/index.dart';
import 'package:bilibili/pages/search/index.dart';
import 'package:bilibili/pages/video/detail/index.dart';
import 'package:bilibili/router/app_pages.dart';
import 'package:bilibili/utils/data.dart';
import 'package:bilibili/utils/global_data.dart';
import 'package:bilibili/utils/recommend_filter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:bilibili/http/init.dart';
import 'package:bilibili/models/common/color_type.dart';
import 'package:bilibili/models/common/theme_type.dart';
import 'package:bilibili/services/loggeer.dart';
import 'package:bilibili/services/service_locator.dart';
import 'package:bilibili/utils/app_scheme.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive/hive.dart';

void main() async {
  // 这行代码在Flutter开发中用于确保Flutter的Widgets层绑定（Binding）已经被初始化。
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // 异步地设置应用程序的首选屏幕方向为竖屏向上（DeviceOrientation.portraitUp）和竖屏向下（DeviceOrientation.portraitDown）。
  // 这意味着，无论用户如何旋转他们的设备，应用程序都将尝试保持屏幕在竖屏模式下显示。
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // 注入缓存 和 Hive // Flutter Hive 是一个在 Flutter 应用中用于数据持久化和状态管理的轻量级库
  await GStrorage.init();
  await setupServiceLocator();
  clearLogs();
  Request();
  await Request.setCookie();
  // 异常捕获 logo记录
  final Catcher2Options releaseConfig =
      Catcher2Options(SilentReportMode(), [FileHandler(await getLogsPath())]);

  Catcher2(
      releaseConfig: releaseConfig,
      runAppFunction: () {
        runApp(const MyApp());
      });

  // 小白条、导航栏沉浸
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 29) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent));
  }

  BillSchame.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Box setting = GStrorage.setting;
    // 主题色
    Color defaultColor =
        colorThemeTypes[setting.get(SettingBoxKey.customColor, defaultValue: 0)]
            ['color'];
    Color brandColor = defaultColor;
    ThemeType currentThemeValue = ThemeType.values[setting
        .get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)];
    // 是否动态取色
    bool isDynamicColor =
        setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
    // 字体缩放大小
    double textScale =
        setting.get(SettingBoxKey.defaultTextScale, defaultValue: 1.0);

    // 强制设置高帧率
    if (Platform.isAndroid) {
      try {
        late List modes;
        FlutterDisplayMode.supported.then((value) {
          modes = value;
          var storageDisplay = setting.get(SettingBoxKey.displayMode);
          DisplayMode f = DisplayMode.auto;
          if (storageDisplay != null) {
            f = modes.firstWhere((e) => e.toString() == storageDisplay);
          }
          DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
          FlutterDisplayMode.setPreferredMode(preferred);
        });
      } catch (_) {}
    }

    if (Platform.isAndroid) {
      return AndroidApp(
        brandColor: brandColor,
        isDynamicColor: isDynamicColor,
        currentThemeValue: currentThemeValue,
        textScale: textScale,
      );
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('1222222'),
        ),
        body: Column(
          children: [
            const Text('地方2'),
            TextField(
                // autofocus: true,
                onChanged: (value) {},
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: '请输入搜索内容',
                  contentPadding: EdgeInsets.all(0),
                  hintStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black54,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AndroidApp extends StatelessWidget {
  final Color brandColor;
  final bool isDynamicColor;
  final ThemeType currentThemeValue;
  final double textScale;
  const AndroidApp(
      {super.key,
      required this.brandColor,
      required this.isDynamicColor,
      required this.currentThemeValue,
      required this.textScale});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.dark,
          );
        }

        return BuildMainApp(
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
          currentThemeValue: currentThemeValue,
          textScale: textScale,
        );
      },
    );
  }
}

class OtherApp extends StatelessWidget {
  final Color brandColor;
  final ThemeType currentThemeValue;
  final double textScale;
  const OtherApp(
      {super.key,
      required this.brandColor,
      required this.currentThemeValue,
      required this.textScale});

  @override
  Widget build(BuildContext context) {
    return BuildMainApp(
      lightColorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.light,
      ),
      darkColorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.dark,
      ),
      currentThemeValue: currentThemeValue,
      textScale: textScale,
    );
  }
}

class BuildMainApp extends StatelessWidget {
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ThemeType currentThemeValue;
  final double textScale;
  const BuildMainApp(
      {super.key,
      required this.lightColorScheme,
      required this.darkColorScheme,
      required this.currentThemeValue,
      required this.textScale});

  @override
  Widget build(BuildContext context) {
    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      actionTextColor: lightColorScheme.primary,
      backgroundColor: lightColorScheme.secondaryContainer,
      closeIconColor: lightColorScheme.secondary,
      contentTextStyle: TextStyle(color: lightColorScheme.secondary),
      elevation: 20,
    );
    return GetMaterialApp(
      title: 'biliPala',
      theme: ThemeData(
        colorScheme: currentThemeValue == ThemeType.dark
            ? darkColorScheme
            : lightColorScheme,
        snackBarTheme: snackBarTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              allowEnterRouteSnapshotting: false,
            ),
          },
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: currentThemeValue == ThemeType.light
            ? lightColorScheme
            : darkColorScheme,
        snackBarTheme: snackBarTheme,
      ),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale("zh", "CN"),
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      fallbackLocale: const Locale("zh", "CN"),
      getPages: Routes.getPages,
      home: const MainApp(),
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(
            toastBuilder: (String msg) => CustomToast(msg: msg),
            child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!));
      },
      // navigatorObservers 是 Flutter 中 MaterialApp 或 WidgetsApp 组件的一个属性，
      // 它允许开发者为应用创建路由观察者（NavigatorObserver）的列表。
      // 这些路由观察者可以监听路由状态的变化，例如路由的推送（push）、弹出（pop）、替换（replace）等事件。
      navigatorObservers: [
        VideoDetailPage.routeObserver,
        SearchPage.routeObserver
      ],
      onInit: () {
        RecommendFilter();
        Data.init();
        GlobalData();
      },
    );
  }
}
