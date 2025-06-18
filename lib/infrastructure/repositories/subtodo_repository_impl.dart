import '../../domain/entities/subtodo.dart';
import '../../domain/repositories/subtodo_repository.dart';
import '../datasources/subtodo_local_datasource.dart';

class SubTodoRepositoryImpl implements SubTodoRepository {
  final SubTodoLocalDatasource datasource;

  SubTodoRepositoryImpl({required this.datasource});

  @override
  Future<void> createSubTodo(SubTodo subTodo, String todoId) {
    return datasource.insertSubTodo(subTodo, todoId);
  }

  @override
  Future<List<SubTodo>> getSubTodos(String todoId) {
    return datasource.getSubTodosByTodoId(todoId);
  }

  @override
  Future<void> toggleSubTodo(String id, bool done) {
    return datasource.toggleSubTodoDone(id, done);
  }

  @override
  Future<void> deleteSubTodo(String id) {
    return datasource.deleteSubTodo(id);
  }
}
