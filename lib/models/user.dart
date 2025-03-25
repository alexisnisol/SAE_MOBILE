class UserModel {
  int id;
  String name;
  String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email
  });

  factory UserModel.createUser(name, email) {
    return UserModel(
      id: 0,
      name: name,
      email: email
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
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