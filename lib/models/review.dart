class Review {
  final int id;
  final int restaurantId;
  final int userId;
  final int etoiles;
  final String avis;
  final DateTime date;
  final String? imageUrl;
  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.etoiles,
    required this.avis,
    required this.date,
    this.imageUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['id_avis'] is int)
          ? json['id_avis']
          : int.tryParse(json['id_avis']?.toString() ?? '0') ?? 0,
      restaurantId: (json['id_restaurant'] is int)
          ? json['id_restaurant']
          : int.tryParse(json['id_restaurant']?.toString() ?? '0') ?? 0,
      userId: (json['id_utilisateur'] is int)
          ? json['id_utilisateur']
          : int.tryParse(json['id_utilisateur']?.toString() ?? '0') ?? 0,
      etoiles: (json['etoile'] is int)
          ? json['etoile']
          : int.tryParse(json['etoile']?.toString() ?? '0') ?? 0,
      avis: json['avis']?.toString() ?? '',
      date: (json['date_avis'] != null && json['date_avis'] is String)
          ? DateTime.tryParse(json['date_avis']) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['image_url'],

    );
  }
}
