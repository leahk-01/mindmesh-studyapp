class SharedNote {
  final String id;
  final String title;
  final String sharedBy;

  SharedNote({required this.id, required this.title, required this.sharedBy});

  factory SharedNote.fromJson(Map<String, dynamic> json) {
    return SharedNote(
      id: json['noteId'],
      title: json['title'],
      sharedBy: json['sharedBy'],
    );
  }
}
