import '../../domain/entities/todo.dart';
import '../models/todo_model.dart';

class TodoMapper {
  static Todo toEntity(TodoModel model) =>
      Todo(
        id: model.id!,
        title: model.title,
        done: model.done == 1,
      );

  static TodoModel toModel(Todo entity) =>
      TodoModel(
        id: entity.id,
        title: entity.title,
        done: entity.done ? 1 : 0,
      );
}