import 'vente_detail_model.dart';

class VenteModel {
  final int id;

  final String clientName;

  final String factureNumero;

  final double total;

  final DateTime? createdAt;

  final List<VenteDetailModel> details;

  VenteModel({
    required this.id,

    required this.clientName,

    required this.factureNumero,

    required this.total,

    required this.createdAt,

    required this.details,
  });

  factory VenteModel.fromJson(Map<String, dynamic> json) {
    return VenteModel(
      id: json['id'] ?? 0,

      clientName: json['client_name'] ?? '',

      factureNumero: json['facture_numero'] ?? '',

      total: double.tryParse(json['total'].toString()) ?? 0,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      details: (json['details'] as List? ?? [])
          .map((e) => VenteDetailModel.fromJson(e))
          .toList(),
    );
  }
}
