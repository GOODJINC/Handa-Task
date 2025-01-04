class Todo {
  int? id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  String color;
  String tag;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.color,
    required this.tag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(), // 2024-12-23 20:27:05.910410
      'color': color, // blue, green, red
      'tag': tag,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      color: map['color'],
      tag: map['tag'],
    );
  }
}
