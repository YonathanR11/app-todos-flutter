import '../../domain/datasources/todo_datasource.dart';
import '../../domain/entities/todo.dart';
import '../mappers/todo_mapper.dart';
import '../models/todo_model.dart';
import 'local_db_datasource.dart';

class TodoLocalDatasource implements TodoDatasource {
  final LocalDBDatasource _db;

  TodoLocalDatasource(this._db);

  @override
  Future<void> insertTodo(Todo todo) async {
    final db = await _db.database;
    final model = TodoMapper.toModel(todo);
    await db.insert('todos', model.toMap());
  }

  @override
  Future<List<Todo>> getTodos() async {
    final db = await _db.database;
    final result = await db.query('todos');
    return result
        .map((row) => TodoMapper.toEntity(TodoModel.fromMap(row)))
        .toList();
  }

  @override
  Future<void> toggleTodoDone(String id, bool done) async {
    final db = await _db.database;
    await db.update(
      'todos',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTodo(String id) async {
    final db = await _db.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
