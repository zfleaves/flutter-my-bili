import 'package:bilibili/pages/about/index.dart';
import 'package:bilibili/pages/blacklist/index.dart';
import 'package:bilibili/pages/dynamics/detail/index.dart';
import 'package:bilibili/pages/dynamics/index.dart';
import 'package:bilibili/pages/fan/index.dart';
import 'package:bilibili/pages/fav/index.dart';
import 'package:bilibili/pages/fav_detail/index.dart';
import 'package:bilibili/pages/fav_search/index.dart';
import 'package:bilibili/pages/follow/index.dart';
import 'package:bilibili/pages/follow_search/index.dart';
import 'package:bilibili/pages/history/index.dart';
import 'package:bilibili/pages/history_search/index.dart';
import 'package:bilibili/pages/home/index.dart';
import 'package:bilibili/pages/hot/index.dart';
import 'package:bilibili/pages/html/index.dart';
import 'package:bilibili/pages/later/index.dart';
import 'package:bilibili/pages/live_room/index.dart';
import 'package:bilibili/pages/login/index.dart';
import 'package:bilibili/pages/media/index.dart';
import 'package:bilibili/pages/member/index.dart';
import 'package:bilibili/pages/member_archive/index.dart';
import 'package:bilibili/pages/member_coin/index.dart';
import 'package:bilibili/pages/member_dynamics/index.dart';
import 'package:bilibili/pages/member_like/index.dart';
import 'package:bilibili/pages/member_search/index.dart';
import 'package:bilibili/pages/member_seasons/index.dart';
import 'package:bilibili/pages/message/at/index.dart';
import 'package:bilibili/pages/message/like/index.dart';
import 'package:bilibili/pages/message/reply/index.dart';
import 'package:bilibili/pages/message/system/index.dart';
import 'package:bilibili/pages/search/index.dart';
import 'package:bilibili/pages/search_result/index.dart';
import 'package:bilibili/pages/setting/index.dart';
import 'package:bilibili/pages/setting/pages/action_menu_set.dart';
import 'package:bilibili/pages/setting/pages/color_select.dart';
import 'package:bilibili/pages/setting/pages/display_mode.dart';
import 'package:bilibili/pages/setting/pages/extra_setting.dart';
import 'package:bilibili/pages/setting/pages/font_size_select.dart';
import 'package:bilibili/pages/setting/pages/home_tabbar_set.dart';
import 'package:bilibili/pages/setting/pages/logs.dart';
import 'package:bilibili/pages/setting/pages/navigation_bar_set.dart';
import 'package:bilibili/pages/setting/pages/play_gesture_set.dart';
import 'package:bilibili/pages/setting/pages/play_setting.dart';
import 'package:bilibili/pages/setting/pages/play_speed_set.dart';
import 'package:bilibili/pages/setting/pages/privacy_setting.dart';
import 'package:bilibili/pages/setting/pages/recommend_setting.dart';
import 'package:bilibili/pages/setting/pages/style_setting.dart';
import 'package:bilibili/pages/subscription/index.dart';
import 'package:bilibili/pages/subscription_detail/index.dart';
import 'package:bilibili/pages/video/detail/index.dart';
import 'package:bilibili/pages/video/detail/reply_reply/index.dart';
import 'package:bilibili/pages/webview/index.dart';
import 'package:bilibili/pages/whisper/index.dart';
import 'package:bilibili/pages/whisper_detail/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

Box<dynamic> setting = GStrorage.setting;

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    // 首页(推荐)
    CustomGetPage(name: '/', page: () => const HomePage()),
    // 热门
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    CustomGetPage(name: '/video', page: () => const VideoDetailPage()),
    // launchUrl
    CustomGetPage(name: '/webview', page: () => const WebviewPage()),
    // 设置
    CustomGetPage(name: '/setting', page: () => const SettingPage()),
    // 媒体库
    CustomGetPage(name: '/media', page: () => const MediaPage()),
    // 我的收藏
    CustomGetPage(name: '/fav', page: () => const FavPage()),
    // 收藏详情页面
    CustomGetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    CustomGetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    CustomGetPage(name: '/history', page: () => const HistoryPage()),
    // 搜索页面
    CustomGetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    CustomGetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    CustomGetPage(name: '/dynamics', page: () => const DynamicsPage()),
    // 动态详情
    CustomGetPage(name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    CustomGetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    CustomGetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    CustomGetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    CustomGetPage(name: '/member', page: () => const MemberPage()),
    // 用户中心搜索页面
    CustomGetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    // 二级回复
    CustomGetPage(name: '/replyReply', page: () => const VideoReplyReplyPanel()),
    // 推荐设置
    CustomGetPage(name: '/recommendSetting', page: () => const RecommendSetting()),
    // 播放设置
    CustomGetPage(name: '/playSetting', page: () => const PlaySetting()),
    // 外观设置
    CustomGetPage(name: '/styleSetting', page: () => const StyleSetting()),
    // 隐私设置
    CustomGetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    // 其他设置
    CustomGetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    // 黑名单管理
    CustomGetPage(name: '/blackListPage', page: () => const BlackListPage()),
    // 应用主题
    CustomGetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    // 首页tabbar
    CustomGetPage(name: '/tabbarSetting', page: () => const TabbarSetPage()),
    // 字体大小设置
    CustomGetPage(name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    CustomGetPage(name: '/displayModeSetting', page: () => const SetDiaplayMode()),
    // 关于
    CustomGetPage(name: '/about', page: () => const AboutPage()),
    // 评论详情
    CustomGetPage(name: '/htmlRender', page: () => const HtmlRenderPage()),
    // 历史记录搜索
    CustomGetPage(name: '/historySearch', page: () => const HistorySearchPage()),
    // 倍速设置
    CustomGetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 收藏搜索
    CustomGetPage(name: '/favSearch', page: () => const FavSearchPage()),
    // 消息页面
    CustomGetPage(name: '/whisper', page: () => const WhisperPage()),
    // 私信详情
    CustomGetPage(name: '/whisperDetail', page: () => const WhisperDetailPage()),
    // 登录页面
    CustomGetPage(name: '/loginPage', page: () => const LoginPage()),
    // 用户动态
    CustomGetPage(name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    // 用户投稿
    CustomGetPage(name: '/memberArchive', page: () => const MemberArchivePage()),
    // 用户最近投币
    CustomGetPage(name: '/memberCoin', page: () => const MemberCoinPage()),
    // 用户最近喜欢
    CustomGetPage(name: '/memberLike', page: () => const MemberLikePage()),
    // 用户专栏
    CustomGetPage(name: '/memberSeasons', page: () => const MemberSeasonsPage()),
    // 日志
    CustomGetPage(name: '/logs', page: () => const LogsPage()),
    // 搜索关注
    CustomGetPage(name: '/followSearch', page: () => const FollowSearchPage()),
    // 订阅
    CustomGetPage(name: '/subscription', page: () => const SubPage()),
    // 订阅详情
    CustomGetPage(name: '/subDetail', page: () => const SubDetailPage()),
    // 播放器手势
    CustomGetPage(name: '/playerGestureSet', page: () => const PlayGesturePage()),
    // navigation bar
    CustomGetPage(name: '/navbarSetting', page: () => const NavigationBarSetPage()),
    // 操作菜单
    CustomGetPage(name: '/actionMenuSet', page: () => const ActionMenuSetPage()),
    // 回复我的
    CustomGetPage(name: '/messageReply', page: () => const MessageReplyPage()),
    // @我的
    CustomGetPage(name: '/messageAt', page: () => const MessageAtPage()),
    // 收到的赞
    CustomGetPage(name: '/messageLike', page: () => const MessageLikePage()),
    // 系统通知
    CustomGetPage(name: '/messageSystem', page: () => const MessageSystemPage()),
  ];
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
