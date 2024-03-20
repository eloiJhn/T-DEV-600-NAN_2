class Board {
  String id;
  String name;
  String? desc;
  bool closed;
  String? idMemberCreator;
  String? idOrganization;
  bool? pinned;
  String? url;
  String? shortUrl;
  String? bgImage;
  String? bgColor;

  Board({
    required this.id,
    required this.name,
    this.desc,
    required this.closed,
    this.idMemberCreator,
    this.idOrganization,
    this.pinned,
    this.url,
    this.shortUrl,
    this.bgImage,
    this.bgColor,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      closed: json['closed'],
      idMemberCreator: json['idMemberCreator'],
      idOrganization: json['idOrganization'],
      pinned: json['pinned'],
      url: json['url'],
      shortUrl: json['shortUrl'],
      bgImage: json['prefs']['backgroundImage'],
      bgColor: json['prefs']['backgroundColor'],
    );
  }

  Board copyWith({
    String? id,
    String? name,
    String? desc,
    bool? closed,
    String? idMemberCreator,
    String? idOrganization,
    bool? pinned,
    String? url,
    String? shortUrl,
    String? bgImage,
    String? bgColor,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      closed: closed ?? this.closed,
      idMemberCreator: idMemberCreator ?? this.idMemberCreator,
      idOrganization: idOrganization ?? this.idOrganization,
      pinned: pinned ?? this.pinned,
      url: url ?? this.url,
      shortUrl: shortUrl ?? this.shortUrl,
      bgImage: bgImage ?? this.bgImage,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}
