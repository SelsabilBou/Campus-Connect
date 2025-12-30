class FileModel {
  final int id;
  final String name;
  final String tag;
  final String url;

  FileModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.url,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
      tag: json['tag'].toString(),
      url: json['url'].toString(),
    );
  }
}
