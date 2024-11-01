import 'package:get/get.dart';
import '../../common/subtitle_type.dart';

class SubTitlteModel {
  SubTitlteModel({
    this.aid,
    this.bvid,
    this.cid,
    this.loginMid,
    this.loginMidHash,
    this.isOwner,
    this.name,
    this.subtitles,
  });

  int? aid;
  String? bvid;
  int? cid;
  int? loginMid;
  String? loginMidHash;
  bool? isOwner;
  String? name;
  List<SubTitlteItemModel>? subtitles;

  factory SubTitlteModel.fromJson(Map<String, dynamic> json) => SubTitlteModel(
        aid: json["aid"],
        bvid: json["bvid"],
        cid: json["cid"],
        loginMid: json["login_mid"],
        loginMidHash: json["login_mid_hash"],
        isOwner: json["is_owner"],
        name: json["name"],
        subtitles: json["subtitle"] != null
            ? json["subtitle"]["subtitles"]
                .map<SubTitlteItemModel>((x) => SubTitlteItemModel.fromJson(x))
                .toList()
            : [],
      );
}

class SubTitlteItemModel {
  SubTitlteItemModel({
    this.id,
    this.lan,
    this.lanDoc,
    this.isLock,
    this.subtitleUrl,
    this.type,
    this.aiType,
    this.aiStatus,
    this.title,
    this.code,
    this.content,
    this.body,
  });

  int? id;
  String? lan;
  String? lanDoc;
  bool? isLock;
  String? subtitleUrl;
  int? type;
  int? aiType;
  int? aiStatus;
  String? title;
  int? code;
  String? content;
  List? body;

  factory SubTitlteItemModel.fromJson(Map<String, dynamic> json) =>
      SubTitlteItemModel(
        id: json["id"],
        lan: json["lan"].replaceAll('-', ''),
        lanDoc: json["lan_doc"],
        isLock: json["is_lock"],
        subtitleUrl: json["subtitle_url"],
        type: json["type"],
        aiType: json["ai_type"],
        aiStatus: json["ai_status"],
        title: json["lan_doc"],
        code: SubtitleType.values
                .firstWhereOrNull(
                    (element) => element.id.toString() == json["lan"])
                ?.index ??
            -1,
        content: '',
        body: [],
      );
}
