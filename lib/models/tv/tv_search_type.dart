import 'package:bilibili/utils/utils.dart';

enum TvSearchType {
  // 电影
  movie,
  // 纪录片
  documentary,
  // 电视剧
  tv,
  // 综艺
  variety,
}

extension TvRankTypeExtension on TvSearchType {
  String get id => ['movie', 'documentary', 'tv', 'variety'][index];
  String get label => ['电影', '纪录片', '电视剧', '综艺'][index];
  int get st => [2, 3, 5, 7][index];
}


Map<String, TvSearchModel> TvSearch = {
  'movie': TvSearchModel(
    key: 'movie',
    st: 2,
    label: '电影',
    orderList: [
      OrderItem(order: 2, sort: 0, label: '播放数量'),
      OrderItem(order: 0, sort: 0, label: '最近更新'),
      OrderItem(order: 6, sort: 0, label: '最近上映'),
      OrderItem(order: 4, sort: 0, label: '最高评分'),
    ],
    areaList: [
      AreaItem(label: '全部地区', id: 'all', area: '-1'),
      AreaItem(label: '中国大陆', id: 'china', area: '1'),
      AreaItem(label: '中国港台', id: 'gangtai', area: '6,7'),
      AreaItem(label: '美国', id: 'american', area: '3'),
      AreaItem(label: '韩国', id: 'korea', area: '8'),
      AreaItem(label: '法国', id: 'france', area: '9'),
      AreaItem(label: '英国', id: 'england', area: '4'),
      AreaItem(label: '德国', id: 'germany', area: '15'),
      AreaItem(label: '泰国', id: 'thailand', area: '10'),
      AreaItem(label: '意大利', id: 'italy', area: '35'),
      AreaItem(label: '西班牙', id: 'spain', area: '13'),
      AreaItem(label: '日本', id: 'japan', area: '2'),
      AreaItem(label: '其他', id: 'other', area: '5,11,12,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70'),
    ],
    styleList: [
      StyleItem(label: '全部风格', id: 'all', styleId: '-1'),
      StyleItem(label: '短片', id: 'ShortFilm', styleId: '10104'),
      StyleItem(label: '剧情', id: 'plot', styleId: '10050'),
      StyleItem(label: '喜剧', id: 'comedy', styleId: '10051'),
      StyleItem(label: '爱情', id: 'love', styleId: '10052'),
      StyleItem(label: '动作', id: 'action', styleId: '10053'),
      StyleItem(label: '恐怖', id: 'terror', styleId: '10054'),
      StyleItem(label: '科幻', id: 'scienceFiction', styleId: '10023'),
      StyleItem(label: '犯罪', id: 'crime', styleId: '10055'),
      StyleItem(label: '惊悚', id: 'thrilling', styleId: '10056'),
      StyleItem(label: '悬疑', id: 'suspense', styleId: '10057'),
      StyleItem(label: '奇幻', id: 'fantasy', styleId: '10018'),
      StyleItem(label: '战争', id: 'war', styleId: '10058'),
      StyleItem(label: '动画', id: 'animation', styleId: '10059'),
      StyleItem(label: '传记', id: 'biography', styleId: '10060'),
      StyleItem(label: '家庭', id: 'family', styleId: '10061'),
      StyleItem(label: '歌舞', id: 'songAndDance', styleId: '10062'),
      StyleItem(label: '历史', id: 'history', styleId: '10033'),
      StyleItem(label: '冒险', id: 'adventure', styleId: '10032'),
      StyleItem(label: '纪实', id: 'documentary', styleId: '10063'),
      StyleItem(label: '灾难', id: 'disaster', styleId: '10064'),
      StyleItem(label: '漫画改', id: 'mangaModification', styleId: '10011'),
      StyleItem(label: '小说改', id: 'novelModification', styleId: '10012'),
    ],
    yearList: Utils.generateYearList(),
    payTypeList: [
      PayTypeItem(id: 'all', label: '付费类型', seasonStatus: '-1'),
      PayTypeItem(id: 'free', label: '免费', seasonStatus: '1'),
      PayTypeItem(id: 'pay', label: '付费', seasonStatus: '2,6'),
      PayTypeItem(id: 'vip', label: '大会员', seasonStatus: '4,6'),
    ]
  ),
  'tv': TvSearchModel(
    key: 'tv',
    st: 5,
    label: '电视剧',
    orderList: [
      OrderItem(order: 2, sort: 0, label: '最多播放'),
      OrderItem(order: 0, sort: 0, label: '最近更新'),
      OrderItem(order: 4, sort: 0, label: '最高评分'),
      OrderItem(order: 1, sort: 0, label: '最多弹幕'),
      OrderItem(order: 3, sort: 0, label: '最多追剧'),
    ],
    areaList: [
      AreaItem(label: '全部地区', id: 'all', area: '-1'),
      AreaItem(label: '中国', id: 'china', area: '1,6,7'),
      AreaItem(label: '日本', id: 'japan', area: '2'),
      AreaItem(label: '美国', id: 'american', area: '3'),
      AreaItem(label: '英国', id: 'england', area: '4'),
      AreaItem(label: '其他', id: 'other', area: '5,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70'),
    ],
    styleList: [
      StyleItem(label: '全部风格', id: 'all', styleId: '-1'),
      StyleItem(label: '剧情', id: 'plot', styleId: '10050'),
      StyleItem(label: '情感', id: 'emotion', styleId: '10084'),
      StyleItem(label: '搞笑', id: 'funny', styleId: '10021'),
      StyleItem(label: '悬疑', id: 'suspense', styleId: '10057'),
      StyleItem(label: '都市', id: 'city', styleId: '10080'),
      StyleItem(label: '家庭', id: 'family', styleId: '10061'),
      StyleItem(label: '古装', id: 'ancientCostume', styleId: '10081'),
      StyleItem(label: '历史', id: 'history', styleId: '10033'),
      StyleItem(label: '奇幻', id: 'fantasy', styleId: '10018'),
      StyleItem(label: '青春', id: 'youth', styleId: '10079'),
      StyleItem(label: '战争', id: 'war', styleId: '10058'),
      StyleItem(label: '武侠', id: 'wuxia', styleId: '10078'),
      StyleItem(label: '励志', id: 'selfImprovement', styleId: '10039'),
      StyleItem(label: '短剧', id: 'shortPlay', styleId: '10103'),
      StyleItem(label: '科幻', id: 'scienceFiction', styleId: '10023'),
      StyleItem(label: '其他', id: 'other', styleId: '10086,10088,10089,10017,10083,10082,10087,10085'),
    ],
    yearList: Utils.generateYearList(),
    payTypeList: payTypeList
  ),
  'documentary': TvSearchModel(
    key: 'documentary',
    st: 3,
    label: '纪录片',
    orderList: [
      OrderItem(order: 2, sort: 0, label: '最多播放'),
      OrderItem(order: 4, sort: 0, label: '最高评分'),
      OrderItem(order: 0, sort: 0, label: '最近更新'),
      OrderItem(order: 6, sort: 0, label: '最近上映'),
      OrderItem(order: 1, sort: 0, label: '最多弹幕'),
    ],
    styleList: [
      StyleItem(label: '全部风格', id: 'all', styleId: '-1'),
      StyleItem(label: '历史', id: 'history', styleId: '10033'),
      StyleItem(label: '美食', id: 'delicious food', styleId: '10045'),
      StyleItem(label: '人文', id: 'humanity', styleId: '10065'),
      StyleItem(label: '科技', id: 'science and technology', styleId: '10066'),
      StyleItem(label: '探险', id: 'explore', styleId: '10067'),
      StyleItem(label: '宇宙', id: 'universe', styleId: '10068'),
      StyleItem(label: '萌宠', id: 'cute pet', styleId: '10069'),
      StyleItem(label: '社会', id: 'society', styleId: '10070'),
      StyleItem(label: '动物', id: 'animal', styleId: '10071'),
      StyleItem(label: '自然', id: 'natural', styleId: '10072'),
      StyleItem(label: '医疗', id: 'medical care', styleId: '10073'),
      StyleItem(label: '军事', id: 'military', styleId: '10074'),
      StyleItem(label: '灾难', id: 'disaster', styleId: '10064'),
      StyleItem(label: '罪案', id: 'Crime', styleId: '10075'),
      StyleItem(label: '神秘', id: 'mysterious', styleId: '10076'),
      StyleItem(label: '旅行', id: 'travel', styleId: '10077'),
      StyleItem(label: '运动', id: 'motion', styleId: '10038'),
      StyleItem(label: '电影', id: 'film', styleId: '-10'),
    ],
    productList: [
      ProducedItem(label: '全部出品', id: 'all', producerId: '-1'),
      ProducedItem(label: '央视', id: 'CCTV', producerId: '4'),
      ProducedItem(label: 'BBC', id: 'BBC', producerId: '1'),
      ProducedItem(label: '探索频道', id: 'Exploration Channel', producerId: '7'),
      ProducedItem(label: '国家地理', id: 'National Geographic', producerId: '14'),
      ProducedItem(label: 'NHK', id: 'NHK', producerId: '2'),
      ProducedItem(label: '历史频道', id: 'History Channel', producerId: '6'),
      ProducedItem(label: '卫视', id: 'Satellite TV', producerId: '8'),
      ProducedItem(label: '自制', id: 'self-control', producerId: '9'),
      ProducedItem(label: 'ITV', id: 'ITV', producerId: '5'),
      ProducedItem(label: 'SKY', id: 'SKY', producerId: '3'),
      ProducedItem(label: 'ZDF', id: 'ZDF', producerId: '10'),
      ProducedItem(label: '合作机构', id: 'Collaborative institutions', producerId: '11'),
      ProducedItem(label: '国内其他', id: 'Domestic Other', producerId: '12'),
      ProducedItem(label: '国外其他', id: 'Other countries abroad', producerId: '13'),
      ProducedItem(label: '索尼', id: 'Sony', producerId: '15'),
      ProducedItem(label: '环球', id: 'world', producerId: '16'),
      ProducedItem(label: '派拉蒙', id: 'Paramount', producerId: '17'),
      ProducedItem(label: '华纳', id: 'warner', producerId: '18'),
      ProducedItem(label: '迪士尼', id: 'Disney', producerId: '19'),
      ProducedItem(label: 'HBO', id: 'HBO', producerId: '20'),
    ],
    yearList: Utils.generateYearList(),
    payTypeList: payTypeList
  ),
  'variety': TvSearchModel(
    key: 'variety',
    st: 7,
    label: '综艺',
    orderList: [
      OrderItem(order: 2, sort: 0, label: '最多播放'),
      OrderItem(order: 0, sort: 0, label: '最近更新'),
      OrderItem(order: 6, sort: 0, label: '最近上映'),
      OrderItem(order: 4, sort: 0, label: '最高评分'),
      OrderItem(order: 1, sort: 0, label: '最多弹幕'),
    ],
    styleList: [
      StyleItem(label: '全部风格', id: 'all', styleId: '-1'),
      StyleItem(label: '音乐', id: 'music', styleId: '10040'),
      StyleItem(label: '访谈', id: 'interview', styleId: '10090'),
      StyleItem(label: '脱口秀', id: 'Talk Show', styleId: '10091'),
      StyleItem(label: '真人秀', id: 'reality show', styleId: '10092'),
      StyleItem(label: '选秀', id: 'draft', styleId: '10094'),
      StyleItem(label: '美食', id: 'delicious food', styleId: '10045'),
      StyleItem(label: '旅游', id: 'Travel', styleId: '10095'),
      StyleItem(label: '晚会', id: 'evening party', styleId: '10098'),
      StyleItem(label: '演唱会', id: 'vocal concert', styleId: '10096'),
      StyleItem(label: '情感', id: 'emotion', styleId: '10084'),
      StyleItem(label: '喜剧', id: 'comedy', styleId: '10095'),
      StyleItem(label: '亲子', id: 'Parenting', styleId: '10097'),
      StyleItem(label: '文化', id: 'Culture', styleId: '10100'),
      StyleItem(label: '职场', id: 'Workplace', styleId: '10048'),
      StyleItem(label: '萌宠', id: 'cute pet', styleId: '10069'),
      StyleItem(label: '养成', id: 'cultivate', styleId: '10099'),
    ],
    payTypeList: payTypeList
  ),
};

class TvSearchModel {
  final String key;
  final int st;
  final String label;
  List<OrderItem> orderList;
  List<AreaItem>? areaList;
  List<StyleItem> styleList;
  List<ProducedItem>? productList;
  List<YearListItem>? yearList;
  List<PayTypeItem> payTypeList;

  TvSearchModel({
    required this.key,
    required this.st,
    required this.label,
    required this.orderList,
    this.areaList,
    this.productList,
    required this.styleList,
    this.yearList,
    required this.payTypeList
  });
}

List<PayTypeItem> payTypeList = [
  PayTypeItem(id: 'all', label: '付费类型', seasonStatus: '-1'),
  PayTypeItem(id: 'free', label: '免费', seasonStatus: '1'),
  PayTypeItem(id: 'vip', label: '大会员', seasonStatus: '4,6'),
];


class OrderItem {
  final int order;
  final int sort;
  final String label;
  OrderItem({
    required this.order,
    required this.sort,
    required this.label,
  });
}

class AreaItem {
  final String label;
  final String id;
  final String area;
 
  AreaItem({
    required this.label,
    required this.id,
    required this.area,
  });
}

class StyleItem {
  final String label;
  final String id;
  final String styleId;
 
  StyleItem({
    required this.label,
    required this.id,
    required this.styleId,
  });
} 

class ProducedItem {
  final String label;
  final String id;
  final dynamic producerId;
 
  ProducedItem({
    required this.label,
    required this.id,
    required this.producerId,
  });
}

class YearListItem {
  final String label;
  final String id;
  final dynamic releaseDate;
 
  YearListItem({
    required this.label,
    required this.id,
    required this.releaseDate,
  });
}


class PayTypeItem {
  final String label;
  final String id;
  final String seasonStatus;
 
  PayTypeItem({
    required this.label,
    required this.id,
    required this.seasonStatus,
  });
}