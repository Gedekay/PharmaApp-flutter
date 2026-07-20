class ProduitVenteModel {
  final int id;
  final String name;
  final String category;
  final int quantite;
  final double price;
  final String emplacement;

  ProduitVenteModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantite,
    required this.price,
    required this.emplacement,
  });

  factory ProduitVenteModel.fromJson(Map<String, dynamic> json) {
    return ProduitVenteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantite: json['quantite'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0,
      emplacement: json['emplacement'] ?? '',
    );
  }
}

class VenteDetailModel {
  final int id;
  final int venteId;
  final int produitId;
  final int quantite;
  final double price;
  final ProduitVenteModel produit;

  VenteDetailModel({
    required this.id,
    required this.venteId,
    required this.produitId,
    required this.quantite,
    required this.price,
    required this.produit,
  });

  factory VenteDetailModel.fromJson(Map<String, dynamic> json) {
    return VenteDetailModel(
      id: json['id'] ?? 0,
      venteId: json['vente_id'] ?? 0,
      produitId: json['produit_id'] ?? 0,
      quantite: json['quantite'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0,
      produit: ProduitVenteModel.fromJson(json['produit']),
    );
  }
}
