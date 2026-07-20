class ProduitModel {
  final int id;
  final String name;
  final String category;
  final int quantite;
  final double price;
  final String emplacement;
  final String? dateExpiration;

  ProduitModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantite,
    required this.price,
    required this.emplacement,
    this.dateExpiration,
  });

  factory ProduitModel.fromJson(Map<String, dynamic> json) {
    return ProduitModel(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      category: json['category'] ?? '',

      quantite: json['quantite'] ?? 0,

      price: double.tryParse(json['price'].toString()) ?? 0,

      emplacement: json['emplacement'] ?? '',

      dateExpiration: json['date_expiration'],
    );
  }
}
