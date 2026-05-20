import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String filter;
  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (filter) {
      case 'done':
        message = 'No completed tasks yet.\nKeep working!';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'active':
        message = 'No active tasks.\nEnjoy your free time!';
        icon = Icons.coffee_outlined;
        break;
      default:
        message = 'No tasks yet.\nTap + to create one!';
        icon = Icons.add_task_rounded;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon,
                size: 40, color: const Color(0xFF6C63FF).withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
