class Note {
  final String id;
  final String title;
  final String? content;

  Note({required this.id, required this.title, this.content});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['noteId'],
      title: json['noteTitle'] ?? '',
      content: json['content'],
    );
  }
}
