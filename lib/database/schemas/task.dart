class Task {
  int? id;
  int userId;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['is_completed'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'is_completed': isCompleted ? 1 : 0
      };
}
