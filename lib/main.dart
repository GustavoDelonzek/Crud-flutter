import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const TodoApp());

class Todo {
  String id;
  String title;
  String description;
  DateTime date;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.completed = false,
  });
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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

  String _generateId() => (_nextId++).toString();

  void _addTodo(Todo newTodo) {
    setState(() => _todos.add(newTodo));
  }

  void _updateTodo(int index, Todo updatedTodo) {
    setState(() => _todos[index] = updatedTodo);
  }

  void _toggleTodoCompleted(int index) {
    setState(() => _todos[index].completed = !_todos[index].completed);
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

  void _confirmDelete(int index) {
    final todo = _todos[index];
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
              setState(() => _todos.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tarefa excluída'),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () => setState(() => _todos.insert(index, todo)),
                  ),
                ),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        )],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: _todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa encontrada',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
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
      color: todo.completed ? Colors.grey[100] : null,
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) => _toggleTodoCompleted(index),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.description,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
                color: todo.completed ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy - HH:mm').format(todo.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
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
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedDate = widget.todo?.date ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: widget.todo?.id ?? widget.generateId?.call() ?? '1',
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        completed: widget.todo?.completed ?? false,
      );
      Navigator.pop(context, newTodo);
    }
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
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Insira um título' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Insira uma descrição' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data e Hora'),
                subtitle: Text(DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 24),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}