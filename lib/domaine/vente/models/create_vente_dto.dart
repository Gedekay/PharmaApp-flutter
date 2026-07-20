class ProduitVenteDto {
  final int id;

  final int quantite;

  ProduitVenteDto({required this.id, required this.quantite});

  Map<String, dynamic> toJson() {
    return {"id": id, "quantite": quantite};
  }
}

class CreateVenteDto {
  final String clientName;

  final List<ProduitVenteDto> produits;

  CreateVenteDto({required this.clientName, required this.produits});

  Map<String, dynamic> toJson() {
    return {
      "client_name": clientName,

      "produits": produits.map((e) => e.toJson()).toList(),
    };
  }
}
