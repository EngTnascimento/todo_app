class Category {
  int? id;
  String name;
  int userId;

  Category({this.id, required this.name, required this.userId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user_id': userId,
      };
}
