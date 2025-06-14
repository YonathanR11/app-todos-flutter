import 'package:uuid/uuid.dart';

import '../../domain/datasources/todo_datasource.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoDatasource datasource;

  TodoRepositoryImpl(this.datasource);

  final uuid = Uuid();

  @override
  Future<void> createTodo(String title) async {
    final newTodo = Todo(id: uuid.v4(), title: title, done: false);
    await datasource.insertTodo(newTodo);
  }

  @override
  Future<List<Todo>> getAllTodos() async {
    final todos = await datasource.getTodos();

    todos.sort((a, b) {
      if (a.done == b.done) return 0;
      return a.done ? 1 : -1;
    });

    return todos;
  }

  @override
  Future<void> toggleTodo(String id, bool done) =>
      datasource.toggleTodoDone(id, done);

  @override
  Future<void> removeTodo(String id) => datasource.deleteTodo(id);
}
