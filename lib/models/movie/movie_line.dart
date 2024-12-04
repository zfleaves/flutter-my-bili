class MovieLineModal {
  String? title;
  List<MovieLineItem>? items;

  MovieLineModal({
    this.title,
    this.items
  });

  MovieLineModal.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    items = json['items'] != null
        ? json['items']
            .map<MovieLineItem>((e) => MovieLineItem.fromJson(e))
            .toList()
        : [];
  }
}


class MovieLineItem {
  String? actors;
  String? cover;
  String? pic;
  String? desc;
  String? link;
  int? seasonId;
  int? seasonType;
  Stat? stat;
  String? styles;
  String? subtitle;
  String? title;
  Rights? rights;
  int? follow;

  MovieLineItem({
    this.actors,
    this.cover,
    this.pic,
    this.desc,
    this.link,
    this.seasonId,
    this.seasonType,
    this.stat,
    this.styles,
    this.subtitle,
    this.title,
    this.rights,
    this.follow,
  });

  MovieLineItem.fromJson(Map<String, dynamic> json) {
    actors = json['actors'];
    cover = json['cover'];
    pic = json['cover'];
    desc = json['desc'];
    link = json['link'];
    seasonId = json['season_id'];
    seasonType = json['season_type'];
    stat = Stat.fromJson(json['stat']);
    styles = json['styles'];
    subtitle = json['subtitle'];
    title = json['title'];
    rights = Rights.fromJson(json['rights']);
    follow = json['follow'] ?? 0;
  }
}

class Rights {
  Rights({
    this.canWatch,
  });

  int? canWatch;

  Rights.fromJson(Map<String, dynamic> json) {
    canWatch = json['can_watch'];
  }
}

class Stat {
  Stat({
    this.follower,
    this.seriesFollow,
  });

  int? follower;
  int? seriesFollow;

  Stat.fromJson(Map<String, dynamic> json) {
    follower = json['follower'];
    seriesFollow = json['seriesFollow'];
  }
}