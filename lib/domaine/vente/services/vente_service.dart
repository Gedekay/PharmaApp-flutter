import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacie_flutter/domaine/vente/models/create_vente_dto.dart';
import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';

class VenteService {
  final String baseUrl = "http://10.252.252.45:8000/api";

  Future<List<VenteModel>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/ventes"),
        headers: {
          "Accept": "application/json",
          "Accept-Encoding": "gzip, deflate, br",
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List data = jsonDecode(decodedBody);
        print("📊 getAll: ${data.length} ventes récupérées");
        return data.map((e) => VenteModel.fromJson(e)).toList();
      }
      throw Exception("Erreur chargement ventes: ${response.statusCode}");
    } on FormatException catch (e) {
      print("❌ Erreur de syntaxe JSON dans getAll() !");
      print("Détails de l'erreur : $e");
      if (e.source is String) {
        final source = e.source as String;
        final offset = e.offset ?? 0;
        final start = (offset - 100).clamp(0, source.length);
        final end = (offset + 100).clamp(0, source.length);
        print(
          "🔍 Extrait du JSON corrompu : ... ${source.substring(start, end)} ...",
        );
      }
      throw Exception(
        "Le serveur a renvoyé des données corrompues (problème de format JSON).",
      );
    } catch (e) {
      print("❌ Erreur imprévue dans getAll(): $e");
      rethrow;
    }
  }

  Future<VenteModel> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/ventes/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(decodedBody);

        print("📥 getById($id) - Structure reçue: ${jsonData.keys}");

        // ✅ La réponse peut être directement la vente ou encapsulée dans 'data'
        Map<String, dynamic> venteData;
        if (jsonData.containsKey('data')) {
          venteData = jsonData['data'] as Map<String, dynamic>;
          print("✅ Vente trouvée dans 'data'");
        } else {
          venteData = jsonData;
          print("✅ Vente en format direct");
        }

        final VenteModel vente = VenteModel.fromJson(venteData);
        print(
          "📊 Vente ${vente.factureNumero}: ${vente.details.length} détails",
        );

        return vente;
      }
      throw Exception("Erreur chargement vente: ${response.statusCode}");
    } on FormatException catch (e) {
      print("❌ Erreur JSON dans getById($id): $e");
      throw Exception("Erreur de format de données reçues du serveur.");
    } catch (e) {
      print("❌ Erreur getById($id): $e");
      rethrow;
    }
  }

  Future<VenteModel> create(CreateVenteDto dto) async {
    try {
      final body = jsonEncode(dto.toJson());
      print("📤 Envoi de la vente: $body");

      final response = await http.post(
        Uri.parse("$baseUrl/ventes"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: body,
      );

      print("📥 Réponse status: ${response.statusCode}");
      print("📥 Réponse body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(decodedBody);

        print("📥 Structure de la réponse: ${jsonData.keys}");

        // ✅ Extraire les données de la vente (peuvent être dans 'data')
        Map<String, dynamic> venteData;

        if (jsonData.containsKey('data')) {
          // ✅ La vente est dans 'data'
          venteData = jsonData['data'] as Map<String, dynamic>;
          print(
            "✅ Vente trouvée dans 'data' avec ${venteData['details']?.length ?? 0} détails",
          );
        } else {
          // ✅ La vente est directement dans la réponse
          venteData = jsonData;
          print(
            "✅ Vente en format direct avec ${venteData['details']?.length ?? 0} détails",
          );
        }

        // ✅ Vérifier que l'ID est présent
        if (!venteData.containsKey('id')) {
          print("❌ L'ID n'est pas présent dans les données");
          print("📊 Données reçues: $venteData");
          throw Exception(
            "L'ID de la vente n'a pas été retourné par le serveur",
          );
        }

        // ✅ Créer la vente à partir des données
        final VenteModel vente = VenteModel.fromJson(venteData);

        print("✅ Vente créée avec succès: ${vente.factureNumero}");
        print("📊 ID: ${vente.id}, Détails: ${vente.details.length}");

        // ✅ Si les détails sont déjà inclus, retourner directement
        if (vente.details.isNotEmpty) {
          print("✅ Les détails sont déjà inclus dans la réponse");

          // ✅ Afficher un aperçu des détails pour vérification
          for (var detail in vente.details) {
            print(
              "  - ${detail.produit.name} x${detail.quantite} = ${detail.price * detail.quantite} FC",
            );
          }

          return vente;
        }

        // ✅ Si pas de détails, essayer de recharger
        print("🔄 Pas de détails dans la réponse, rechargement de la vente...");

        try {
          final VenteModel venteComplete = await getById(vente.id);
          print(
            "✅ Vente complète récupérée avec ${venteComplete.details.length} détails",
          );

          if (venteComplete.details.isNotEmpty) {
            for (var detail in venteComplete.details) {
              print(
                "  - ${detail.produit.name} x${detail.quantite} = ${detail.price * detail.quantite} FC",
              );
            }
          }

          return venteComplete;
        } catch (reloadError) {
          print("❌ Erreur lors du rechargement: $reloadError");
          // ✅ Retourner la vente sans détails plutôt que de planter
          print("⚠️ Retour de la vente sans détails");
          return vente;
        }
      } else {
        // ✅ Gérer les erreurs de validation
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values
                .map((e) => e is List ? e.join(', ') : e.toString())
                .join('\n');
            throw Exception("Erreur de validation: $errorMessages");
          }
          throw Exception("Erreur ${response.statusCode}: ${response.body}");
        } catch (e) {
          throw Exception("Erreur ${response.statusCode}: ${response.body}");
        }
      }
    } catch (e) {
      print("❌ Erreur createVente: $e");
      rethrow;
    }
  }

  Future<void> update({required int id, required double total}) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/ventes/$id"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({"total": total}),
      );

      if (response.statusCode != 200) {
        throw Exception("Erreur mise à jour vente: ${response.statusCode}");
      }
      print("✅ Vente $id mise à jour avec succès");
    } catch (e) {
      print("❌ Erreur update($id): $e");
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/ventes/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Erreur suppression vente: ${response.statusCode}");
      }
      print("✅ Vente $id supprimée avec succès");
    } catch (e) {
      print("❌ Erreur delete($id): $e");
      rethrow;
    }
  }

  // ✅ Méthode utilitaire pour diagnostiquer une vente
  void diagnosticVente(VenteModel vente) {
    print("\n📋 DIAGNOSTIC VENTE");
    print("═══════════════════════════════════════");
    print("🆔 ID: ${vente.id}");
    print("📄 Facture: ${vente.factureNumero}");
    print("👤 Client: ${vente.clientName}");
    print("💰 Total: ${vente.total.toStringAsFixed(0)} FC");
    print("📅 Date: ${vente.createdAt}");
    print("📊 Détails: ${vente.details.length}");

    if (vente.details.isNotEmpty) {
      print("\n📦 LISTE DES PRODUITS:");
      for (var i = 0; i < vente.details.length; i++) {
        final detail = vente.details[i];
        print("  ${i + 1}. ${detail.produit.name}");
        print("     📦 Qté: ${detail.quantite}");
        print("     💰 Prix unitaire: ${detail.price.toStringAsFixed(0)} FC");
        print(
          "     💵 Total: ${(detail.price * detail.quantite).toStringAsFixed(0)} FC",
        );
        print("     📂 Catégorie: ${detail.produit.category}");
        print("     📍 Emplacement: ${detail.produit.emplacement}");
        print("     ──────────────────────────");
      }
    } else {
      print("\n⚠️  Aucun détail trouvé !");
      print("🔍 Vérifiez que le backend renvoie bien les détails.");
      print("🔍 Vérifiez la structure de la réponse JSON.");
    }
    print("═══════════════════════════════════════\n");
  }
}
