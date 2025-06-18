class Todo {
  final String? id;
  final String title;
  final bool done;

  // 👇 nuevas propiedades opcionales para mostrar en la lista
  final int? completedSubtasks;
  final int? totalSubtasks;

  Todo({
    required this.id,
    required this.title,
    required this.done,
    this.completedSubtasks,
    this.totalSubtasks,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? done,
    int? completedSubtasks,
    int? totalSubtasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
    );
  }
}
