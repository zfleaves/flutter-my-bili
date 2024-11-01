import 'package:bilibili/http/index.dart';
import 'package:bilibili/utils/constants.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class SetCookie {
  static onSet() async {
    var cookies = await WebviewCookieManager().getCookies(HttpString.baseUrl);
    await Request.cookieManager.cookieJar.saveFromResponse(Uri.parse(HttpString.baseUrl), cookies);
    String cookieString = cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    Request.dio.options.headers['cookie'] = cookieString;
    
    cookies = await WebviewCookieManager().getCookies(HttpString.apiBaseUrl);
    await Request.cookieManager.cookieJar.saveFromResponse(Uri.parse(HttpString.apiBaseUrl), cookies);
    await Request.cookieManager.cookieJar.saveFromResponse(Uri.parse(HttpString.tUrl), cookies);
  }
}