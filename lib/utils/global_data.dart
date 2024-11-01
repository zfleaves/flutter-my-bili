import 'package:bilibili/models/common/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:hive/hive.dart';

Box setting = GStrorage.setting;

class GlobalData {
  int imgQuality = 10;

  FullScreenGestureMode fullScreenGestureMode =
      FullScreenGestureMode.values.last;

  bool enablePlayerControlAnimation = true;
  final bool enableMYBar =
      setting.get(SettingBoxKey.enableMYBar, defaultValue: true);
  List<String> actionTypeSort = setting.get(SettingBoxKey.actionTypeSort,
      defaultValue: ['like', 'coin', 'collect', 'watchLater', 'share']);
  
  // 私有构造函数
  GlobalData._();

  // 单例实例
  static final GlobalData _instance = GlobalData._();

  // 获取全局实例
  factory GlobalData() => _instance;
}
