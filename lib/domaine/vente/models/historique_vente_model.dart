// historique_vente_model.dart
class HistoriqueVenteModel {
  final int id;
  final String clientName;
  final String factureNumero;
  final double total;
  final int totalProduits;
  final DateTime? createdAt;
  final List<HistoriqueVenteDetailModel> details;

  HistoriqueVenteModel({
    required this.id,
    required this.clientName,
    required this.factureNumero,
    required this.total,
    required this.totalProduits,
    this.createdAt,
    this.details = const [],
  });

  factory HistoriqueVenteModel.fromJson(Map<String, dynamic> json) {
    final details = (json['details'] as List? ?? [])
        .map((e) => HistoriqueVenteDetailModel.fromJson(e))
        .toList();

    return HistoriqueVenteModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? '',
      factureNumero: json['facture_numero'] ?? '',
      total: double.tryParse(json['total'].toString()) ?? 0,
      totalProduits: details.fold(0, (sum, detail) => sum + detail.quantite),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      details: details,
    );
  }
}

class HistoriqueVenteDetailModel {
  final int id;
  final int produitId;
  final String produitName;
  final int quantite;
  final double price;

  HistoriqueVenteDetailModel({
    required this.id,
    required this.produitId,
    required this.produitName,
    required this.quantite,
    required this.price,
  });

  factory HistoriqueVenteDetailModel.fromJson(Map<String, dynamic> json) {
    return HistoriqueVenteDetailModel(
      id: json['id'] ?? 0,
      produitId: json['produit_id'] ?? 0,
      produitName: json['produit']['name'] ?? json['product_name'] ?? '',
      quantite: json['quantite'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }
}
