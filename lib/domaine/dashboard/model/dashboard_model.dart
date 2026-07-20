class DashboardModel {
  final int produits;
  final int ventes;
  final int stockFaible;
  final List<ProduitStock> stockFaibleList;
  final double ca;

  DashboardModel({
    required this.produits,
    required this.ventes,
    required this.stockFaible,
    required this.stockFaibleList,
    required this.ca,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      produits: json['produits'] ?? 0,

      ventes: json['ventes'] ?? 0,

      stockFaible: json['stock_faible'] ?? 0,

      stockFaibleList: (json['stock_faible_list'] as List? ?? [])
          .map((e) => ProduitStock.fromJson(e))
          .toList(),

      ca: double.tryParse(json['ca']?.toString() ?? "0") ?? 0,
    );
  }
}

class ProduitStock {
  final int id;

  final String name;

  final String category;

  final int quantite;

  final String emplacement;

  final double price;

  ProduitStock({
    required this.id,

    required this.name,

    required this.category,

    required this.quantite,

    required this.emplacement,

    required this.price,
  });

  factory ProduitStock.fromJson(Map<String, dynamic> json) {
    return ProduitStock(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      category: json['category'] ?? '',

      quantite: json['quantite'] ?? 0,

      emplacement: json['emplacement'] ?? '',

      price: double.tryParse(json['price']?.toString() ?? "0") ?? 0,
    );
  }
}
