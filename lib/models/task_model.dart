enum Priority { low, medium, high }

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final Priority priority;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.priority,
    this.deadline,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: Priority.values.firstWhere(
        (p) => p.name == (map['priority'] as String? ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    Priority? priority,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
