class TrelloOrganization {

  final String id;
  final String displayName;
  final String description;

  TrelloOrganization({
    required this.id,
    required this.displayName,
    required this.description,
  });

  factory TrelloOrganization.fromJson(Map<String, dynamic> json) {
    return TrelloOrganization(
      id: json['id'],
      displayName: json['displayName'],
      description: json['desc'],
      // Add other fields as necessary...
    );
  }
}