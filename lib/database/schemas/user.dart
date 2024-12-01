class User {
  int? id;
  String email;
  String password;
  String? darkTheme;

  User({this.id, required this.email, required this.password, this.darkTheme});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      darkTheme: json['darkTheme'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'dark_theme': darkTheme ?? 0,
      };
}
