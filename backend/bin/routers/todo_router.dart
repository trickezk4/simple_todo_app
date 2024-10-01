import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/todo_model.dart';

class TodoRouter {
  final _todos = <TodoModel>[];

  Router get router {
    final router = Router();

    router.get('/todos', _getTodoHandler);

    router.post('/todos', _addTodoHandler);

    router.delete('/todos/<id>', _deleteHandler);
    return router;
  }

  static final _headers = {'Content-Type': 'application/json'};

  Future<Response> _getTodoHandler(Request req) async {
    try{
      final body = json.encode(_todos.map((todo) => todo.toMap()).toList());
      return Response.ok(
        body,
        headers: _headers
      );
    } catch(e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers
      );
    }
  }

  Future<Response> _addTodoHandler(Request req) async {
    try{
      final payload = await req.readAsString();
      final data = json.decode(payload);
      final todo = TodoModel.fromMap(data);
      _todos.add(todo);
      return Response.ok(
        todo.toJson(),
        headers: _headers
      );
    } catch(e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers
      );
    }
  }

  Future<Response> _deleteHandler(Request req, String id) async {
    try{
      final index = _todos.indexWhere((todo) => todo.id == int.parse(id));
      
      if(index == -1) {
        return Response.notFound('Không tìm thấy todo có id = $id');
      }

      final removeTodo = _todos.removeAt(index);
      return Response.ok(
        removeTodo.toJson(),
        headers: _headers
      );
    } catch(e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _headers
      );
    }
  } 
}