import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/todo_repository.dart';
import '../../infrastructure/datasources/local_db_datasource.dart';
import '../../infrastructure/datasources/todo_local_datasource.dart';
import '../../infrastructure/repositories/todo_repository_impl.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final db = LocalDBDatasource();
  final datasource = TodoLocalDatasource(db);
  return TodoRepositoryImpl(datasource);
});
