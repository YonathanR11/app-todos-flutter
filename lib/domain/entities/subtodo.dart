class SubTodo {
  final String id;
  final String title;
  final bool done;

  SubTodo({required this.id, required this.title, required this.done});

  SubTodo copyWith({required String id}) {
    return SubTodo(id: id, title: title, done: done);
  }
}
