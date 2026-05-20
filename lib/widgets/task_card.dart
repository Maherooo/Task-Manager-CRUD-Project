import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.deadline != null &&
        task.deadline!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: task.isCompleted ? const Color(0xFF6C63FF)
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Color.fromARGB(255, 4, 0, 0))
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: task.isCompleted
                          ? Colors.grey[400]
                          : const Color(0xFF1A1A2E),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PriorityBadge(priority: task.priority),
                      const SizedBox(width: 8),
                      if (task.deadline != null)
                        _DeadlineBadge(
                            deadline: task.deadline!, isOverdue: isOverdue),
                    ],
                  ),
                ],
              ),
            ),

            // Actions menu
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: Icon(Icons.more_vert_rounded,
                  size: 20, color: Colors.grey[400]),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Delete',
                        style: TextStyle(color: Colors.redAccent)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final Priority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (priority) {
      case Priority.low:
        color = const Color(0xFF4CAF50);
        label = 'Low';
        break;
      case Priority.medium:
        color = const Color(0xFFFF9800);
        label = 'Medium';
        break;
      case Priority.high:
        color = const Color(0xFFF44336);
        label = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final DateTime deadline;
  final bool isOverdue;
  const _DeadlineBadge({required this.deadline, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? Colors.redAccent : Colors.grey[500]!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          DateFormat('dd MMM').format(deadline),
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
        if (isOverdue)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('· Overdue',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}
