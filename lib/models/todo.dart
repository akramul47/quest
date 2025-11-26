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

class Subtask {
  String id;
  String title;
  bool isCompleted;

  Subtask({required this.id, required this.title, this.isCompleted = false});

  Subtask copyWith({String? title, bool? isCompleted}) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Todo {
  String id;
  String task;
  String? description; // "The why"
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  bool isArchived;
  TodoPriority priority;
  List<Subtask> subtasks;
  DateTime? dateTime; // Scheduled date/time
  DateTime? deadline; // Deadline

  Todo({
    required this.id,
    required this.task,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.isArchived = false,
    this.priority = TodoPriority.sideQuest,
    List<Subtask>? subtasks,
    this.dateTime,
    this.deadline,
  }) : subtasks = subtasks ?? [];

  Todo copyWith({
    String? task,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isArchived,
    TodoPriority? priority,
    List<Subtask>? subtasks,
    DateTime? dateTime,
    DateTime? deadline,
    bool clearDescription = false,
    bool clearDateTime = false,
    bool clearDeadline = false,
  }) {
    return Todo(
      id: id,
      task: task ?? this.task,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      isArchived: isArchived ?? this.isArchived,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      dateTime: clearDateTime ? null : (dateTime ?? this.dateTime),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'task': task,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'isArchived': isArchived,
    'priority': priority.index,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'dateTime': dateTime?.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
  };

  Todo.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      task = json['task'],
      description = json['description'],
      isCompleted = json['isCompleted'],
      createdAt = DateTime.parse(json['createdAt']),
      completedAt = json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      isArchived = json['isArchived'] ?? false,
      priority = json['priority'] != null
          ? TodoPriority.values[json['priority']]
          : TodoPriority.sideQuest,
      subtasks =
          (json['subtasks'] as List<dynamic>?)
              ?.map((s) => Subtask.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      dateTime = json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : null,
      deadline = json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null;
}
