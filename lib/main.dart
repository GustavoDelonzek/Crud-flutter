import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class Todo {
  String id;
  String title;
  String description;
  DateTime date;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  int _nextId = 1;

  String _generateId() {
    return (_nextId++).toString();
  }

  void _addTodo(Todo newTodo) {
    setState(() => _todos.add(newTodo));
  }

  void _updateTodo(int index, Todo updatedTodo) {
    setState(() => _todos[index] = updatedTodo);
  }

  void _deleteTodo(int index) {
    setState(() => _todos.removeAt(index));
  }

  void _navigateToFormScreen(BuildContext context, int? index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoFormScreen(
          todo: index != null ? _todos[index] : null,
          generateId: index == null ? _generateId : null),
      ),
    );

    if (result != null && index != null) {
      _updateTodo(index, result);
    } else if (result != null) {
      _addTodo(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: _todos.isEmpty
          ? const Center(child: Text('Nenhuma tarefa encontrada'))
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) => _buildTodoItem(index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToFormScreen(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoItem(int index) {
    final todo = _todos[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(todo.title),
        subtitle: Text(todo.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToFormScreen(context, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(index),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _deleteTodo(index);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;
  final String Function()? generateId;

  const TodoFormScreen({super.key, this.todo, this.generateId});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Insira um título' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Insira uma descrição' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTodo,
                child: const Text('Salvar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: widget.todo?.id ?? widget.generateId?.call() ?? '1',
        title: _titleController.text,
        description: _descriptionController.text,
        date: DateTime.now(),
      );
      Navigator.pop(context, newTodo);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}