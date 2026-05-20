import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_router.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final tasks = await _taskService.fetchTasks();
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {
      if (mounted) _showError('Failed to load tasks.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleComplete(TaskModel task) async {
    try {
      await _taskService.toggleComplete(task);
      await _loadTasks();
    } catch (_) {
      if (mounted) _showError('Could not update task.');
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete task?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${task.title}"?',
            style: TextStyle(color: Colors.grey[600])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _taskService.deleteTask(task.id);
      await _loadTasks();
      if (mounted) _showSuccess('Task deleted.');
    } catch (_) {
      if (mounted) _showError('Could not delete task.');
    }
  }

  void _showSnack(String msg, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showError(String msg) =>
      _showSnack(msg, Colors.redAccent, icon: Icons.error_outline);

  void _showSuccess(String msg) =>
      _showSnack(msg, const Color(0xFF4CAF50));

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, AppRouter.login);
  }

  List<TaskModel> get _filteredTasks => switch (_filter) {
        'active' => _tasks.where((t) => !t.isCompleted).toList(),
        'done'   => _tasks.where((t) => t.isCompleted).toList(),
        _        => _tasks,
      };

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(email.split('@').first,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded,
                        size: 20, color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),
            if (_tasks.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_completedCount of ${_tasks.length} completed',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        Text('${((_completedCount / _tasks.length) * 100).round()}%',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 200, 144, 3),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _completedCount / _tasks.length,
                        backgroundColor: const Color(0xFFEEEEFF),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

            // Filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  _filterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _filterChip('Done', 'done'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Task list
            Expanded(
              child: _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                  : _filteredTasks.isEmpty
                      ? EmptyState(filter: _filter)
                      : RefreshIndicator(
                          onRefresh: _loadTasks,
                          color: const Color(0xFF6C63FF),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (_, i) => TaskCard(
                              task: _filteredTasks[i],
                              onToggle: () => _toggleComplete(_filteredTasks[i]),
                              onEdit: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRouter.editTask,
                                  arguments: _filteredTasks[i],
                                );
                                _loadTasks();
                              },
                              onDelete: () => _deleteTask(_filteredTasks[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRouter.addTask);
          _loadTasks();
        },
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6C63FF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey[600],
            )),
      ),
    );
  }
}