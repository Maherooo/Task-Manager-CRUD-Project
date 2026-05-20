import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _taskService = TaskService();

  Priority _priority = Priority.medium;
  DateTime? _deadline;
  bool _loading = false;

  bool get _isEdit => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.existingTask!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _priority = t.priority;
      _deadline = t.deadline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6C63FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  String? get _descValue {
    final v = _descCtrl.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await _taskService.updateTask(
          widget.existingTask!.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descValue,
            priority: _priority,
            deadline: _deadline,
          ),
        );
      } else {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        await _taskService.createTask(TaskModel(
          id: '',
          userId: userId,
          title: _titleCtrl.text.trim(),
          description: _descValue,
          priority: _priority,
          deadline: _deadline,
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Failed to save task: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Color _priorityColor(Priority p) => switch (p) {
        Priority.low => const Color(0xFF4CAF50),
        Priority.medium => const Color(0xFFFF9800),
        Priority.high => const Color(0xFFF44336),
      };

  IconData _priorityIcon(Priority p) => switch (p) {
        Priority.low => Icons.south_rounded,
        Priority.medium => Icons.remove_rounded,
        Priority.high => Icons.north_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        title: Text(
          _isEdit ? 'Edit Task' : 'New Task',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Task title',
                hint: 'Enter your task title?',
                prefixIcon: Icons.edit_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 3) return 'Title too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'Add details...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text('Priority',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              Row(
                children: Priority.values.map((p) {
                  final selected = _priority == p;
                  final color = _priorityColor(p);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: p != Priority.high ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? color : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? color : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_priorityIcon(p),
                                size: 20,
                                color: selected ? Colors.white : Colors.grey[500]),
                            const SizedBox(height: 4),
                            Text(
                              p.name[0].toUpperCase() + p.name.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Deadline',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _deadline != null
                          ? const Color(0xFF6C63FF).withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 20,
                          color: _deadline != null
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[400]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deadline != null
                              ? DateFormat('EEE, dd MMM yyyy').format(_deadline!)
                              : 'No deadline set',
                          style: TextStyle(
                            color: _deadline != null
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey[400],
                            fontWeight: _deadline != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _deadline = null),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: _isEdit ? 'Save Changes' : 'Create Task',
                loading: _loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}