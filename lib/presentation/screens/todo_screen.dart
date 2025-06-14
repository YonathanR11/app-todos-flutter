import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_viewer2/sqlite_viewer.dart';

import '../../domain/entities/todo.dart';
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

  List<Todo> _todos = [];

  Future<void> _loadTodos() async {
    final repo = ref.read(todoRepositoryProvider);
    final todos = await repo.getAllTodos();
    setState(() {
      _todos = todos;
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

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nueva tarea...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _todos.isEmpty
                ? const Center(child: Text('Sin tareas aún...'))
                : ListView(
                    children: [
                      // TODOs pendientes
                      ..._todos.where((t) => !t.done).map(_buildTodoTile),

                      // Separador
                      if (_todos.any((t) => t.done)) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              Divider(thickness: 2),
                              Text(
                                'Completados',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // TODOs completados
                      ..._todos.where((t) => t.done).map(_buildTodoTile),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DatabaseList()),
                );
              },
              tooltip: 'Ver base de datos',
              child: const Icon(Icons.storage),
            )
          : null,
    );
  }

  Widget _buildTodoTile(Todo todo) {
    return Opacity(
      opacity: todo.done ? 0.5 : 1.0,
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done ? Colors.grey : null,
          ),
        ),
        leading: Checkbox(
          value: todo.done,
          onChanged: (_) => _toggleTodo(todo),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteTodo(todo.id!),
        ),
      ),
    );
  }
}
