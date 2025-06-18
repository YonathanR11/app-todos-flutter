import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todos/presentation/screens/subtodo_screen.dart';

import '../../domain/entities/todo.dart';
import '../../infrastructure/datasources/subtodo_local_datasource.dart';
import '../providers/theme_provider.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends ConsumerStatefulWidget {
  static const name = 'todo-screen';

  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final _subtodoDs = SubTodoLocalDatasource();
  List<Todo> _todos = [];




  Future<void> _loadTodos() async {
    final repo = ref.read(todoRepositoryProvider);
    final todos = await repo.getAllTodos();

    final todosWithCounts = await Future.wait(todos.map(_withSubTodoCount));

    setState(() {
      _todos = todosWithCounts;
    });
  }

  Future<void> _addTodo() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(todoRepositoryProvider);
    await repo.createTodo(title);
    _controller.clear();
    await _loadTodos();
  }

  Future<void> _toggleTodo(Todo todo) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.toggleTodo(todo.id!, !todo.done);
    await _loadTodos();
  }

  Future<void> _deleteTodo(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.removeTodo(id);
    await _loadTodos();
  }

  Future<Todo> _withSubTodoCount(Todo todo) async {
    final subtodos = await _subtodoDs.getSubTodosByTodoId(todo.id!);
    final total = subtodos.length;
    final done = subtodos.where((e) => e.done).length;

    return todo.copyWith(completedSubtasks: done, totalSubtasks: total);
  }

  bool _isInProgress(Todo t) {
    final total = t.totalSubtasks ?? 0;
    final done = t.completedSubtasks ?? 0;

    // Mostrar si no hay subtareas, o si hay algunas pero no todas están completas
    return !t.done && (total == 0 || done < total);
  }

  bool _isCompleted(Todo t) =>
      (t.totalSubtasks ?? 0) > 0 &&
      (t.completedSubtasks ?? 0) == (t.totalSubtasks ?? 0);

  void _showAddTodoModal() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(
          context,
        ).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nueva tarea', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Escribe tu tarea...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) async {
                await _addTodo();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _addTodo();
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('Sin tareas'));
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoTile(todo);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final totalCount = _todos.length;
    final inProgressCount = _todos.where(_isInProgress).length;
    final completedCount = _todos.where(_isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis TODOs'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Todos ($totalCount)'),
                Tab(text: 'En progreso ($inProgressCount)'),
                Tab(text: 'Completados ($completedCount)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTodoList(_todos),
                  // Todos
                  _buildTodoList(_todos.where(_isInProgress).toList()),
                  // En progreso
                  _buildTodoList(_todos.where(_isCompleted).toList()),
                  // Completados
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoTile(Todo todo) {
    return Opacity(
      opacity: todo.done ? 0.5 : 1.0,
      child: ListTile(
        leading: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (todo.totalSubtasks ?? 0) == 0
                    ? 0
                    : (todo.completedSubtasks ?? 0) / (todo.totalSubtasks ?? 1),
                strokeWidth: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
              ),
              Text(
                todo.totalSubtasks == null || todo.totalSubtasks == 0
                    ? '0%'
                    : '${((todo.completedSubtasks ?? 0) / todo.totalSubtasks! * 100).round()}%',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done ? Colors.grey : null,
          ),
        ),
        onTap: () async {
          await context.pushNamed(
            SubTodoScreen.name,
            pathParameters: {'id': todo.id!, 'title': todo.title},
          );
          _loadTodos();
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') _deleteTodo(todo.id!);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red[400]),
                  const SizedBox(width: 1),
                  const Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
