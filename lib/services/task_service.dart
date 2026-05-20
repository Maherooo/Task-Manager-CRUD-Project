import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  final _client = Supabase.instance.client;
  static const _table = 'tasks';

  String get _userId => _client.auth.currentUser!.id;

  Future<List<TaskModel>> fetchTasks() async {
    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _client
        .from(_table)
        .insert(task.toMap())
        .select()
        .single();
    return TaskModel.fromMap(data);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final data = await _client
        .from(_table)
        .update(task.toMap())
        .eq('id', task.id)
        .select()
        .single();
    return TaskModel.fromMap(data);
  }

  Future<void> toggleComplete(TaskModel task) async {
    await _client
        .from(_table)
        .update({'is_completed': !task.isCompleted})
        .eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
