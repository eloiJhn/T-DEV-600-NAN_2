class TrelloCard {
  final String id;
  // final String address;
  // final Map<String, dynamic> badges;
  // final List<String> checkItemStates;
  // final bool closed;
  // final String coordinates;
  // final String creationMethod;
  // final DateTime dateLastActivity;
  final String desc;
  // final Map<String, dynamic> descData;
  final String? due;
  // final String dueReminder;
  // final String email;
  final String idBoard;
  // final List<Map<String, String>> idChecklists;
  // final List<Map<String, String>> idLabels;
  // final String idList;
  final List<String> idMembers;
  // final List<String> idMembersVoted;
  // final int idShort;
  // final List<String> labels;
  // final Map<String, dynamic> limits;
  // final String locationName;
  // final bool manualCoverAttachment;
  final String name;
  // final int pos;
  // final String shortLink;
  // final String shortUrl;
  // final bool subscribed;
  // final String url;
  // final Map<String, dynamic> cover;

  TrelloCard({
    required this.id,
    // required this.address,
    // required this.badges,
    // required this.checkItemStates,
    // required this.closed,
    // required this.coordinates,
    // required this.creationMethod,
    // required this.dateLastActivity,
    required this.desc,
    // required this.descData,
    this.due,
    // required this.dueReminder,
    // required this.email,
    required this.idBoard,
    // required this.idChecklists,
    // required this.idLabels,
    // required this.idList,
    required this.idMembers,
    // required this.idMembersVoted,
    // required this.idShort,
    // required this.labels,
    // required this.limits,
    // required this.locationName,
    // required this.manualCoverAttachment,
    required this.name,
    // required this.pos,
    // required this.shortLink,
    // required this.shortUrl,
    // required this.subscribed,
    // required this.url,
    // required this.cover,
  });

  factory TrelloCard.fromJson(Map<String, dynamic> json) {
    return TrelloCard(
      id: json['id'],
      // address: json['address'],
      // badges: json['badges'],
      // checkItemStates: List<String>.from(json['checkItemStates']),
      // closed: json['closed'],
      // coordinates: json['coordinates'],
      // creationMethod: json['creationMethod'],
      // dateLastActivity: DateTime.parse(json['dateLastActivity']),
      desc: json['desc'],
      // descData: json['descData'],
      due: json['due'],
      // dueReminder: json['dueReminder'],
      // email: json['email'],
      idBoard: json['idBoard'],
      // idChecklists: List<Map<String, String>>.from(json['idChecklists']),
      // idLabels: List<Map<String, String>>.from(json['idLabels']),
      // idList: json['idList'],
      idMembers: List<String>.from(json['idMembers']),
      // idMembersVoted: List<String>.from(json['idMembersVoted']),
      // idShort: json['idShort'],
      // labels: List<String>.from(json['labels']),
      // limits: json['limits'],
      // locationName: json['locationName'],
      // manualCoverAttachment: json['manualCoverAttachment'],
      name: json['name'],
      // pos: json['pos'],
      // shortLink: json['shortLink'],
      // shortUrl: json['shortUrl'],
      // subscribed: json['subscribed'],
      // url: json['url'],
      // cover: json['cover'],
    );
  }
}
