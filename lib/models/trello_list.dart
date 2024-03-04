class TrelloList {
  final String id;
  final String name;
  // final bool closed;
  // final int pos;
  // final String softLimit;
  // final String idBoard;
  // final bool subscribed;
  // final Map<String, dynamic> limits;

  TrelloList({
    required this.id,
    required this.name,
    // required this.closed,
    // required this.pos,
    // required this.softLimit,
    // required this.idBoard,
    // required this.subscribed,
    // required this.limits,
  });

  factory TrelloList.fromJson(Map<String, dynamic> json) {
    return TrelloList(
      id: json['id'],
      name: json['name'],
      // closed: json['closed'],
      // pos: json['pos'],
      // softLimit: json['softLimit'],
      // idBoard: json['idBoard'],
      // subscribed: json['subscribed'],
      // limits: json['limits'],
    );
  }
}
