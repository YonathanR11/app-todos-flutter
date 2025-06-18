import '../entities/subtodo.dart';

abstract class SubTodoRepository {
  Future<void> createSubTodo(SubTodo subTodo, String todoId);

  Future<List<SubTodo>> getSubTodos(String todoId);

  Future<void> toggleSubTodo(String id, bool done);

  Future<void> deleteSubTodo(String id);
}
