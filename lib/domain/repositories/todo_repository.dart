import '../entities/todo.dart';

abstract class TodoRepository {
  Future<void> createTodo(String title);

  Future<List<Todo>> getAllTodos();

  Future<void> toggleTodo(String id, bool done);

  Future<void> removeTodo(String id);
}
