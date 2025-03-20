class Restaurant {
  final String name;

  Restaurant({required this.name});

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(name: map['name']);
  }
}