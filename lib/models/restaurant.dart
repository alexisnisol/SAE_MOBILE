class Restaurant {
  final int id_restaurant;
  final String name;
  final String operator;
  final String brand;
  final String opening_hours;
  final bool wheelchair;
  final bool vegetarian;
  final bool vegan;
  final bool delivery;
  final bool takeaway;
  final String internet_access;
  final int stars;
  final int capacity;
  final bool drive_through;
  final String wikidata;
  final String brand_wikidata;
  final String siret;
  final String phone;
  final String website;
  final String facebook;
  final bool smoking;
  final int com_insee;
  final String com_nom;
  final String region;
  final int code_region;
  final String departement;
  final int code_departement;
  final String commune;
  final int code_commune;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id_restaurant,
    required this.name,
    required this.operator,
    required this.brand,
    required this.opening_hours,
    required this.wheelchair,
    required this.vegetarian,
    required this.vegan,
    required this.delivery,
    required this.takeaway,
    required this.internet_access,
    required this.stars,
    required this.capacity,
    required this.drive_through,
    required this.wikidata,
    required this.brand_wikidata,
    required this.siret,
    required this.phone,
    required this.website,
    required this.facebook,
    required this.smoking,
    required this.com_insee,
    required this.com_nom,
    required this.region,
    required this.code_region,
    required this.departement,
    required this.code_departement,
    required this.commune,
    required this.code_commune,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromMap(Map<String, dynamic> restaurant) {
    return Restaurant(
      id_restaurant: restaurant['id_restaurant'] ?? 0,
      name: restaurant['name'] ?? '',
      operator: restaurant['operator'] ?? '',
      brand: restaurant['brand'] ?? '',
      opening_hours: restaurant['opening_hours'] ?? '',
      wheelchair: _parseBool(restaurant['wheelchair']),
      vegetarian: _parseBool(restaurant['vegetarian']),
      vegan: _parseBool(restaurant['vegan']),
      delivery: _parseBool(restaurant['delivery']),
      takeaway: _parseBool(restaurant['takeaway']),
      internet_access: restaurant['internet_access'] ?? '',
      stars: _parseInt(restaurant['stars']),
      capacity: _parseInt(restaurant['capacity']),
      drive_through: _parseBool(restaurant['drive_through']),
      wikidata: restaurant['wikidata'] ?? '',
      brand_wikidata: restaurant['brand_wikidata'] ?? '',
      siret: restaurant['siret'] ?? '',
      phone: restaurant['phone'] ?? '',
      website: restaurant['website'] ?? '',
      facebook: restaurant['facebook'] ?? '',
      smoking: _parseBool(restaurant['smoking']),
      com_insee: _parseInt(restaurant['com_insee']),
      com_nom: restaurant['com_nom'] ?? '',
      region: restaurant['region'] ?? '',
      code_region: _parseInt(restaurant['code_region']),
      departement: restaurant['departement'] ?? '',
      code_departement: _parseInt(restaurant['code_departement']),
      commune: restaurant['commune'] ?? '',
      code_commune: _parseInt(restaurant['code_commune']),
      latitude: _parseDouble(restaurant['latitude']),
      longitude: _parseDouble(restaurant['longitude']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
