import '../../domain/entities/subtodo.dart';
import '../models/subtodo_model.dart';

class SubTodoMapper {
  static SubTodoModel toModel(SubTodo entity, String todoId) {
    return SubTodoModel(
      id: entity.id,
      todoId: todoId,
      title: entity.title,
      done: entity.done ? 1 : 0,
    );
  }

  static SubTodo toEntity(SubTodoModel model) {
    return SubTodo(id: model.id, title: model.title, done: model.done == 1);
  }
}
