import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

  Future<void> _addSubTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final sub = SubTodo(id: _uuid.v4(), title: text, done: false);
    await _subtodoDs.insertSubTodo(sub, widget.todoId);
    _controller.clear();
    _loadSubTodos();
  }

  Future<void> _toggleSubTodo(SubTodo sub) async {
    await _subtodoDs.toggleSubTodoDone(sub.id, !sub.done);
    _loadSubTodos();
  }

  Future<void> _deleteSubTodo(String id) async {
    await _subtodoDs.deleteSubTodo(id);
    _loadSubTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subtareas de: ${widget.todoTitle}')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 100.0,
                  // ⬅️ Ajusta el tamaño del círculo
                  lineWidth: 25.0,
                  // ⬅️ Grosor del trazo
                  percent: _subtodos.isEmpty
                      ? 0
                      : _subtodos.where((e) => e.done).length /
                            _subtodos.length,
                  center: Text(
                    _subtodos.isEmpty
                        ? '0%'
                        : '${((_subtodos.where((e) => e.done).length / _subtodos.length) * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: Colors.black87,
                  backgroundColor: Colors.grey[300]!,
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  animationDuration: 500,
                ),

                Text(
                  _subtodos.isEmpty
                      ? '0%'
                      : '${((_subtodos.where((e) => e.done).length / _subtodos.length) * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nueva subtarea...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSubTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubTodo,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _subtodos.isEmpty
                ? const Center(child: Text('Sin subtareas'))
                : ListView.builder(
                    itemCount: _subtodos.length,
                    itemBuilder: (context, index) {
                      final sub = _subtodos[index];
                      return Opacity(
                        opacity: sub.done ? 0.5 : 1,
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
