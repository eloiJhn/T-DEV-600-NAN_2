class Board {
  String id;
  String name;
  //String desc;
  bool closed;
  String? idMemberCreator;
  String idOrganization;
  bool pinned;
  String url;
  String shortUrl;
  String? bgImage;
  String? bgColor;
  /*
  Map<String, String> labelNames;
  Map<String, dynamic> limits;
  bool starred;
  String memberships;
  String shortLink;
  bool subscribed;
  String powerUps;
  String dateLastActivity;
  String dateLastView;
  String idTags;
  String datePluginDisable;
  String creationMethod;
  int ixUpdate;
  String templateGallery;
  bool enterpriseOwned;
  */

  Board({
    required this.id,
    required this.name,
    //required this.desc,
    required this.closed,
    this.idMemberCreator,
    required this.idOrganization,
    required this.pinned,
    required this.url,
    required this.shortUrl,
    this.bgImage,
    this.bgColor,
    /*
    required this.labelNames,
    required this.limits,
    required this.starred,
    required this.memberships,
    required this.shortLink,
    required this.subscribed,
    required this.powerUps,
    required this.dateLastActivity,
    required this.dateLastView,
    required this.idTags,
    required this.datePluginDisable,
    required this.creationMethod,
    required this.ixUpdate,
    required this.templateGallery,
    required this.enterpriseOwned,
    */
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      //desc: json['desc'],
      closed: json['closed'],
      idMemberCreator: json['idMemberCreator'],
      idOrganization: json['idOrganization'],
      pinned: json['pinned'],
      url: json['url'],
      shortUrl: json['shortUrl'],
      bgImage: json['prefs']['backgroundImage'],
      bgColor: json['prefs']['backgroundColor'],
      /*
      labelNames: Map<String, String>.from(json['labelNames']),
      limits: Map<String, dynamic>.from(json['limits']),
      starred: json['starred'],
      memberships: json['memberships'],
      shortLink: json['shortLink'],
      subscribed: json['subscribed'],
      powerUps: json['powerUps'],
      dateLastActivity: json['dateLastActivity'],
      dateLastView: json['dateLastView'],
      idTags: json['idTags'],
      datePluginDisable: json['datePluginDisable'],
      creationMethod: json['creationMethod'],
      ixUpdate: json['ixUpdate'],
      templateGallery: json['templateGallery'],
      enterpriseOwned: json['enterpriseOwned'],
       */
    );
  }
}
