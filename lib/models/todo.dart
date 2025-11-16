import 'package:flutter/material.dart';

enum TodoPriority {
  mainQuest,
  sideQuest;

  String get displayName {
    switch (this) {
      case TodoPriority.mainQuest:
        return 'Main Quest';
      case TodoPriority.sideQuest:
        return 'Side Quest';
    }
  }

  IconData get icon {
    switch (this) {
      case TodoPriority.mainQuest:
        return Icons.star;
      case TodoPriority.sideQuest:
        return Icons.assignment;
    }
  }
}

class Todo {
  String id;
  String task;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  bool isArchived;
  TodoPriority priority;

  Todo({
    required this.id,
    required this.task,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.isArchived = false,
    this.priority = TodoPriority.sideQuest,
  });

  // ... (previous methods remain the same)

  Todo copyWith({
    String? task,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isArchived,
    TodoPriority? priority,
  }) {
    return Todo(
      id: id,
      task: task ?? this.task,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'task': task,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isArchived': isArchived,
        'priority': priority.index,
      };

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        task = json['task'],
        isCompleted = json['isCompleted'],
        createdAt = DateTime.parse(json['createdAt']),
        completedAt = json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        isArchived = json['isArchived'] ?? false,
        priority = json['priority'] != null
            ? TodoPriority.values[json['priority']]
            : TodoPriority.sideQuest;
}
