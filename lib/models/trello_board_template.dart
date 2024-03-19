class TrelloBoardTemplate {
  final String id;
  final String name;
  final String description;
  String? backgroundImage;
  String? backgroundColor;
  final int viewCount;
  final int copyCount;

  TrelloBoardTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.backgroundImage,
    this.backgroundColor,
    required this.viewCount,
    required this.copyCount,
  });

  factory TrelloBoardTemplate.fromJson(Map<String, dynamic> json) {
    return TrelloBoardTemplate(
      id: json['id'],
      name: json['name'],
      description: json['desc'],
      backgroundImage: json['prefs']['backgroundImage'],
      backgroundColor: json['prefs']['backgroundColor'],
      viewCount: json['templateGallery']['stats']['viewCount'],
      copyCount: json['templateGallery']['stats']['copyCount'],
    );
  }
}
