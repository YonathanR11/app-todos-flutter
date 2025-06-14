import '../entities/todo.dart';

abstract class TodoDatasource {
  Future<void> insertTodo(Todo todo);

  Future<List<Todo>> getTodos();

  Future<void> toggleTodoDone(String id, bool done);

  Future<void> deleteTodo(String id);
}
