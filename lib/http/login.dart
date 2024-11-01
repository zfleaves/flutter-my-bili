import 'dart:convert';
import 'dart:math';

import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/login/index.dart';
import 'package:bilibili/utils/constants.dart';
import 'package:bilibili/utils/login.dart';
import 'package:dio/dio.dart';

class LoginHttp {
  static Future queryCaptcha() async {
    var res = await Request().get(Api.getCaptcha);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': CaptchaDataModel.fromJson(res.data['data']),
      };
    } else {
      return {'status': false, 'data': res.message};
    }
  }

  // web端验证码
  static Future sendWebSmsCode({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    Map data = {
      'cid': cid,
      'tel': tel,
      "source": "main_web",
      'token': token,
      'challenge': challenge,
      'validate': validate,
      'seccode': seccode,
    };
    FormData formData = FormData.fromMap({...data});
    var res = await Request().post(
      Api.webSmsCode,
      data: formData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // web端验证码登录
  static Future loginInByWebSmsCode({
    int? cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    // webSmsLogin
    Map data = {
      "cid": cid,
      "tel": tel,
      "code": code,
      "source": "main_mini",
      "keep": 0,
      "captcha_key": captchaKey,
      "go_url": HttpString.baseUrl
    };
    FormData formData = FormData.fromMap({...data});
    var res = await Request().post(
      Api.webSmsLogin,
      data: formData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 获取盐hash跟PubKey
  static Future getWebKey() async {
    var res = await Request().get(Api.getWebKey,
        data: {'disable_rcmd': 0, 'local_id': LoginUtils.generateBuvid()});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': {}, 'msg': res.data['message']};
    }
  }

  // web端密码登录
  static Future loginInByWebPwd({
    required int username,
    required String password,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    Map data = {
      'username': username,
      'password': password,
      'keep': 0,
      'token': token,
      'challenge': challenge,
      'validate': validate,
      'seccode': seccode,
      'source': 'main-fe-header',
      "go_url": HttpString.baseUrl
    };
    FormData formData = FormData.fromMap({...data});
    var res = await Request().post(
      Api.loginInByWebPwd,
      data: formData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // web端登录二维码
  static Future getWebQrcode() async {
    var res = await Request().get(Api.qrCodeApi);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // web端二维码轮询登录状态
  static Future queryWebQrcodeStatus(String qrcodeKey) async {
    var res = await Request().get(Api.loginInByQrcode, data: {'qrcode_key': qrcodeKey});
    if (res.data['data']['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }
}