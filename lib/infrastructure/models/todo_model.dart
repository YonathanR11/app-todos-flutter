class TodoModel {
  final String? id;
  final String title;
  final int done; // 0 = false, 1 = true

  TodoModel({this.id, required this.title, required this.done});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'done': done};
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(id: map['id'], title: map['title'], done: map['done']);
  }
}
