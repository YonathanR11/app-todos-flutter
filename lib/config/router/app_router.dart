import 'package:go_router/go_router.dart';
import 'package:prueba_a/presentation/screens/todo_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: TodoScreen.name,
      builder: (context, state) => const TodoScreen(),
    ),
  ],
);
