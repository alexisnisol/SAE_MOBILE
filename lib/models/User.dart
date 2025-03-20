class User {
  int id;
  String name;
  String email;

  User({
    required this.id,
    required this.name,
    required this.email
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email']
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email
    };
  }

}