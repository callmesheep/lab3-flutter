import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> _todoItems = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  // Lấy đường dẫn thư mục lưu trữ
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path + '/list.json';
  }

  // Lưu danh sách công việc vào file
  Future<void> _saveTodoItems() async {
    String filePath = await _getFilePath();
    File file = File(filePath);
    String jsonItems = jsonEncode(_todoItems);
    file.writeAsString(jsonItems);
  }

  // Tải danh sách công việc từ file
  Future<void> _loadTodoItems() async {
    String filePath = await _getFilePath();
    File file = File(filePath);
    if (file.existsSync()) {
      String jsonItems = await file.readAsString();
      List<dynamic> items = jsonDecode(jsonItems);
      setState(() {
        _todoItems = List<String>.from(items);
      });
    }
  }

  // Thêm công việc vào danh sách
  void _addTodoItem(String item) {
    if (item.isNotEmpty) {
      setState(() {
        _todoItems.add(item);
      });
      _controller.clear();
      _saveTodoItems(); // Lưu lại danh sách sau khi thêm
    }
  }

  // Xóa công việc khỏi danh sách
  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems(); // Lưu lại danh sách sau khi xóa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Nhập công việc',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addTodoItem(_controller.text),
                  child: Text('Thêm'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoItems[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodoItem(index),
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