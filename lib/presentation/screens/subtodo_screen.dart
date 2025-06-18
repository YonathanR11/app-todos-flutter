import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subtodo.dart';
import '../../infrastructure/datasources/subtodo_local_datasource.dart';

class SubTodoScreen extends StatefulWidget {
  static const String name = 'subtodo-screen';

  final String todoId;
  final String todoTitle;

  const SubTodoScreen({
    super.key,
    required this.todoId,
    required this.todoTitle,
  });

  @override
  State<SubTodoScreen> createState() => _SubTodoScreenState();
}

class _SubTodoScreenState extends State<SubTodoScreen> {
  final _controller = TextEditingController();
  final _subtodoDs = SubTodoLocalDatasource();
  final _uuid = const Uuid();
  bool _hasChanges = false;

  List<SubTodo> _subtodos = [];

  @override
  void initState() {
    super.initState();
    _loadSubTodos();
  }

  Future<void> _loadSubTodos() async {
    final subtodos = await _subtodoDs.getSubTodosByTodoId(widget.todoId);
    setState(() {
      _subtodos = subtodos;
    });
  }

  Future<void> _addSubTodo(String title) async {
    if (title.trim().isEmpty) return;
    final sub = SubTodo(id: _uuid.v4(), title: title.trim(), done: false);
    await _subtodoDs.insertSubTodo(sub, widget.todoId);
    _hasChanges = true;
    await _loadSubTodos();
  }

  Future<void> _toggleSubTodo(SubTodo sub) async {
    await _subtodoDs.toggleSubTodoDone(sub.id, !sub.done);
    _hasChanges = true;
    await _loadSubTodos();
  }

  Future<void> _deleteSubTodo(String id) async {
    await _subtodoDs.deleteSubTodo(id);
    _hasChanges = true;
    await _loadSubTodos();
  }

  void _showAddModal() {
    _controller.clear();
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
            const Text('Nueva subtarea', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Escribe una subtarea...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                _addSubTodo(_controller.text);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _addSubTodo(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _subtodos.where((e) => e.done).length;
    final total = _subtodos.length;
    final percent = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(title: Text(widget.todoTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50, width: 50),
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 25,
            percent: percent,
            center: Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(fontSize: 20),
            ),
            progressColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.grey[300]!,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 500,
          ),
          const SizedBox(height: 25),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Subtodos ($total)', style: const TextStyle(fontSize: 16)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddModal,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _subtodos.isEmpty
                ? const Center(child: Text('Sin subtareas...'))
                : ListView.builder(
                    itemCount: _subtodos.length,
                    itemBuilder: (context, index) {
                      final sub = _subtodos[index];
                      return Opacity(
                        opacity: sub.done ? 0.5 : 1.0,
                        child: ListTile(
                          title: Text(
                            sub.title,
                            style: TextStyle(
                              decoration: sub.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          leading: Checkbox(
                            value: sub.done,
                            onChanged: (_) => _toggleSubTodo(sub),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteSubTodo(sub.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
