class SubTodoModel {
  final String id;
  final String todoId;
  final String title;
  final int done;

  SubTodoModel({
    required this.id,
    required this.todoId,
    required this.title,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'todo_id': todoId, 'title': title, 'done': done};
  }

  factory SubTodoModel.fromMap(Map<String, dynamic> map) {
    return SubTodoModel(
      id: map['id'],
      todoId: map['todo_id'],
      title: map['title'],
      done: map['done'],
    );
  }
}
