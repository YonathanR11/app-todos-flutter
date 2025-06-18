import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subtodo.dart';
import 'local_db_datasource.dart';
import '../mappers/subtodo_mapper.dart';
import '../models/subtodo_model.dart';

class SubTodoLocalDatasource {
  final _db = LocalDBDatasource();
  final _uuid = const Uuid();

  Future<void> insertSubTodo(SubTodo subTodo, String todoId) async {
    final db = await _db.database;
    final model = SubTodoMapper.toModel(
      subTodo.copyWith(id: _uuid.v4()),
      todoId,
    );
    await db.insert('subtodos', model.toMap());
  }

  Future<List<SubTodo>> getSubTodosByTodoId(String todoId) async {
    final db = await _db.database;
    final result = await db.query(
      'subtodos',
      where: 'todo_id = ?',
      whereArgs: [todoId],
    );
    return result
        .map((e) => SubTodoMapper.toEntity(SubTodoModel.fromMap(e)))
        .toList();
  }

  Future<void> toggleSubTodoDone(String subTodoId, bool isDone) async {
    final db = await _db.database;
    await db.update(
      'subtodos',
      {'done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subTodoId],
    );
  }

  Future<void> deleteSubTodo(String subTodoId) async {
    final db = await _db.database;
    await db.delete('subtodos', where: 'id = ?', whereArgs: [subTodoId]);
  }
}
