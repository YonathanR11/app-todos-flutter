import 'package:go_router/go_router.dart';
import 'package:todos/presentation/screens/todo_screen.dart';

import '../../presentation/screens/subtodo_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: TodoScreen.name,
      builder: (context, state) => const TodoScreen(),
    ),
    GoRoute(
      path: '/subtodos/:id/:title',
      name: SubTodoScreen.name,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final title = state.pathParameters['title']!;
        return SubTodoScreen(todoId: id, todoTitle: title);
      },
    ),
  ],
);
