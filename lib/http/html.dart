import 'dart:convert';

import 'package:bilibili/http/index.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class HtmlHttp {
  // article
  static Future reqHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/opus/$id",
      extra: {'ua': 'pc'},
    );

    if (response.data.contains('Redirecting to')) {
      RegExp regex = RegExp(r'//([\w\.]+)/(\w+)/(\w+)');
      Match match = regex.firstMatch(response.data)!;
      String matchedString = match.group(0)!;
      response = await Request().get(
        'https:$matchedString/',
        extra: {'ua': 'pc'},
      );
    }

    try {
      Document rootTree = parse(response.data);
      // log(response.data.body.toString());
      Element body = rootTree.body!;
      Element appDom = body.querySelector('#app')!;
      Element authorHeader = appDom.querySelector('.fixed-author-header')!;
      // 头像
      String avatar = authorHeader.querySelector('img')!.attributes['src']!;
      avatar = 'https:${avatar.split('@')[0]}';
      String uname = authorHeader
          .querySelector('.fixed-author-header__author__name')!
          .text;
      // 动态详情
      Element opusDetail = appDom.querySelector('.opus-detail')!;
      // 发布时间
      String updateTime =
          opusDetail.querySelector('.opus-module-author__pub__text')!.text;
      //
      String opusContent =
          opusDetail.querySelector('.opus-module-content')!.innerHtml;
      String? test;
      try {
        test = opusDetail
            .querySelector('.horizontal-scroll-album__pic__img')!
            .innerHtml;
      } catch (_) {}

      String commentId = opusDetail
          .querySelector('.bili-comment-container')!
          .className
          .split(' ')[1]
          .split('-')[2];
      // List imgList = opusDetail.querySelectorAll('bili-album__preview__picture__img');
      return {
        'status': true,
        'avatar': avatar,
        'uname': uname,
        'updateTime': updateTime,
        'content': (test ?? '') + opusContent,
        'commentId': int.parse(commentId)
      };
    } catch (err) {
      print('err: $err');
    }
  }

  // read
  static Future reqReadHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/$dynamicType/$id/",
      extra: {'ua': 'pc'},
    );
    if (response.data.contains('Redirecting to')) {
      RegExp regex = RegExp(r'//([\w\.]+)/(\w+)/(\w+)');
      Match match = regex.firstMatch(response.data)!;
      String matchedString = match.group(0)!;
      response = await Request().get(
        'https:$matchedString/',
        extra: {'ua': 'pc'},
      );
    }
    Document rootTree = parse(response.data);
    Element body = rootTree.body!;
    Element appDom = body.querySelector('#app')!;
    Element authorHeader = appDom.querySelector('.up-left')!;

    // 头像
    // String avatar =
    //     authorHeader.querySelector('.bili-avatar-img')!.attributes['data-src']!;
    // print(avatar);
    // avatar = 'https:${avatar.split('@')[0]}';
    String uname = authorHeader.querySelector('.up-name')!.text.trim();
    // 动态详情
    Element opusDetail = appDom.querySelector('.article-content')!;
    // 发布时间
    // String updateTime =
    //     opusDetail.querySelector('.opus-module-author__pub__text')!.text;
    // print(updateTime);

    String opusContent =
        opusDetail.querySelector('#read-article-holder')!.innerHtml;
    RegExp digitRegExp = RegExp(r'\d+');
    Iterable<Match> matches = digitRegExp.allMatches(id);
    String number = matches.first.group(0)!;
    return {
      'status': true,
      'avatar': '',
      'uname': uname,
      'updateTime': '',
      'content': opusContent,
      'commentId': int.parse(number)
    };
  }

  static Future reqHtmlMovie({required int seasonId}) async {
    var response = await Request().get(
      "https://www.bilibili.com/bangumi/play/ss$seasonId?theme=movie",
      extra: {'ua': 'pc'},
    );

    Document rootTree = parse(response.data);
    // print(rootTree);
    // print(rootTree.outerHtml);
    String playurlSSRDataStr = getStringBetween(rootTree.outerHtml, 'const playurlSSRData = ', 'if (playurlSSRData) {');
    // print(playurlSSRDataStr);
    // 使用 jsonDecode 将字符串转换为 Dart 对象（Map<String, dynamic>）
    Map<String, dynamic> result = jsonDecode(playurlSSRDataStr);
    // print(result);
    return result;
  }

  static String getStringBetween(String source, String startTag, String endTag) {
    int startIndex = source.indexOf(startTag);
    if (startIndex == -1) return ""; // 如果没有找到开始标记，返回空字符串
  
    startIndex += startTag.length; // 跳过开始标记的长度
  
    int endIndex = source.indexOf(endTag, startIndex);
    if (endIndex == -1) return ""; // 如果没有找到结束标记，返回空字符串
  
    return source.substring(startIndex, endIndex); // 返回开始和结束标记之间的字符串
  }
}