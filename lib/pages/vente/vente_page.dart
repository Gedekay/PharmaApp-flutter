import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharmacie_flutter/pages/vente/vente_controller.dart';
import 'package:pharmacie_flutter/pages/dashboard/dashboard_controller.dart';
import 'package:pharmacie_flutter/pages/produit/produit_controller.dart';
import 'package:pharmacie_flutter/domaine/vente/models/create_vente_dto.dart';
import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';
import 'package:pharmacie_flutter/domaine/facture/facture_pdf_service.dart';

class VentePage extends StatefulWidget {
  const VentePage({super.key});

  @override
  State<VentePage> createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> {
  final Map<int, int> panier = {};
  final TextEditingController clientController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final Map<int, TextEditingController> _quantityControllers = {};

  static const Color primaryGreen = Color(0xFF00B074);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color softGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProduitController>().loadProduits();
    });
  }

  @override
  void dispose() {
    clientController.dispose();
    searchController.dispose();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
    super.dispose();
  }

  double get total {
    double somme = 0;
    final produits = context.read<ProduitController>().state.produits;
    for (final item in panier.entries) {
      try {
        final produit = produits.firstWhere((p) => p.id == item.key);
        somme += produit.price * item.value;
      } catch (e) {
        // Produit non trouvé, ignorer
      }
    }
    return somme;
  }

  int get totalItems {
    int count = 0;
    for (final item in panier.entries) {
      count += item.value;
    }
    return count;
  }

  void ajouterProduit(int id, int quantite) {
    setState(() {
      if (quantite <= 0) {
        panier.remove(id);
        _quantityControllers.remove(id);
      } else {
        panier[id] = quantite;
        if (_quantityControllers.containsKey(id)) {
          _quantityControllers[id]?.text = quantite.toString();
        }
      }
    });
  }

  void supprimerProduit(int id) {
    setState(() {
      panier.remove(id);
      _quantityControllers.remove(id);
    });
  }

  void viderPanier() {
    setState(() {
      panier.clear();
      _quantityControllers.clear();
    });
  }

  TextEditingController _getQuantityController(
    int productId,
    int initialValue,
  ) {
    if (!_quantityControllers.containsKey(productId)) {
      _quantityControllers[productId] = TextEditingController(
        text: initialValue.toString(),
      );
    }
    return _quantityControllers[productId]!;
  }

  Future<void> validerVente() async {
    if (clientController.text.trim().isEmpty) {
      _showSnackbar(
        context,
        "Veuillez saisir le nom de l'acheteur",
        Colors.redAccent,
      );
      return;
    }

    if (panier.isEmpty) {
      _showSnackbar(
        context,
        "Veuillez sélectionner des produits",
        Colors.redAccent,
      );
      return;
    }

    try {
      final dto = CreateVenteDto(
        clientName: clientController.text.trim(),
        produits: panier.entries
            .map((e) => ProduitVenteDto(id: e.key, quantite: e.value))
            .toList(),
      );

      _showProgressDialog(context);

      // ✅ Créer la vente - le service retourne maintenant une vente avec détails
      final VenteModel? vente = await context
          .read<VenteController>()
          .createVente(dto);

      if (!mounted) return;

      // ✅ Fermer le loader d'attente
      Navigator.pop(context);

      if (vente != null) {
        // ✅ Afficher un diagnostic de la vente
        print("\n📋 VENTE CRÉÉE AVEC SUCCÈS");
        print("═══════════════════════════════════════");
        print("🆔 ID: ${vente.id}");
        print("📄 Facture: ${vente.factureNumero}");
        print("👤 Client: ${vente.clientName}");
        print("💰 Total: ${vente.total.toStringAsFixed(0)} FC");
        print("📊 Détails: ${vente.details.length}");

        if (vente.details.isNotEmpty) {
          print("\n📦 PRODUITS:");
          for (var i = 0; i < vente.details.length; i++) {
            final detail = vente.details[i];
            print(
              "  ${i + 1}. ${detail.produit.name} x${detail.quantite} = ${(detail.price * detail.quantite).toStringAsFixed(0)} FC",
            );
          }
        } else {
          print("\n⚠️ Aucun détail trouvé dans la vente !");
        }
        print("═══════════════════════════════════════\n");

        // ✅ Vider le panier et réinitialiser
        setState(() {
          panier.clear();
          _quantityControllers.clear();
          clientController.clear();
        });

        // ✅ Mettre à jour le dashboard
        await context.read<DashboardController>().loadDashboard();

        // ✅ Gérer l'impression de la facture
        VenteModel venteAImprimer = vente;

        // ✅ Si la vente n'a pas de détails, essayer de les charger
        if (vente.details.isEmpty) {
          print("🔄 Tentative de rechargement des détails de la vente...");
          try {
            final venteRechargee = await context
                .read<VenteController>()
                .service
                .getById(vente.id);

            if (venteRechargee.details.isNotEmpty) {
              venteAImprimer = venteRechargee;
              print(
                "✅ Détails rechargés avec succès: ${venteRechargee.details.length} produits",
              );
            } else {
              print("⚠️ La vente rechargée n'a toujours pas de détails");
            }
          } catch (e) {
            print("❌ Erreur lors du rechargement: $e");
          }
        }

        // ✅ Vérifier à nouveau si la vente a des détails
        if (venteAImprimer.details.isNotEmpty && mounted) {
          try {
            print(
              "📄 Génération de la facture pour ${venteAImprimer.factureNumero}...",
            );

            await FacturePdfService.imprimerAvecDialogue(
              context,
              venteAImprimer,
            );

            if (mounted) {
              _showSnackbar(
                context,
                "Facture ${venteAImprimer.factureNumero} créée avec succès",
                primaryGreen,
              );
            }
          } catch (pdfError) {
            print("❌ Erreur PDF: $pdfError");
            if (mounted) {
              _showSnackbar(
                context,
                "Vente créée mais erreur d'impression: ${pdfError.toString()}",
                Colors.orangeAccent,
              );
              // ✅ Proposer une alternative en cas d'échec
              _showPrintRetryDialog(context, venteAImprimer);
            }
          }
        } else {
          // ✅ Pas de détails disponibles
          print("⚠️ Impossible d'imprimer la facture: aucun détail disponible");
          if (mounted) {
            _showSnackbar(
              context,
              "Vente ${vente.factureNumero} créée avec succès",
              Colors.green,
            );
          }
        }

        // ✅ Retourner à la page précédente
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final error = context.read<VenteController>().state.error;
        if (mounted) {
          _showSnackbar(
            context,
            error ?? "Erreur lors de la création de la vente",
            Colors.redAccent,
          );
        }
      }
    } catch (e) {
      print("❌ Erreur validerVente: $e");
      if (mounted) {
        // ✅ Fermer le dialogue de progression s'il est encore ouvert
        try {
          Navigator.pop(context);
        } catch (_) {}

        _showSnackbar(context, "Erreur: ${e.toString()}", Colors.redAccent);
      }
    }
  }

  // ✅ Dialogue de réessai en cas d'échec de l'impression
  void _showPrintRetryDialog(BuildContext context, VenteModel vente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Problème d'impression",
          style: TextStyle(color: darkSlate, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "La facture n'a pas pu être générée automatiquement.",
              style: TextStyle(color: softGrey),
            ),
            const SizedBox(height: 8),
            Text(
              "Facture: ${vente.factureNumero}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Client: ${vente.clientName}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Total: ${vente.total.toStringAsFixed(0)} FC",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Vous pouvez réessayer ou consulter la vente dans la liste des ventes.",
              style: TextStyle(color: softGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: primaryGreen)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                // ✅ Tenter de charger la vente depuis le service
                final venteRechargee = await context
                    .read<VenteController>()
                    .service
                    .getById(vente.id);

                if (venteRechargee.details.isNotEmpty) {
                  await FacturePdfService.imprimerAvecDialogue(
                    context,
                    venteRechargee,
                  );
                  if (mounted) {
                    _showSnackbar(
                      context,
                      "Facture imprimée avec succès",
                      primaryGreen,
                    );
                  }
                } else {
                  if (mounted) {
                    _showSnackbar(
                      context,
                      "Toujours aucun détail disponible pour la facture",
                      Colors.orangeAccent,
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  _showSnackbar(
                    context,
                    "Erreur: ${e.toString()}",
                    Colors.redAccent,
                  );
                }
              }
            },
            icon: const Icon(Icons.print, size: 18),
            label: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  // ✅ Méthode pour charger une vente avec plusieurs tentatives
  Future<VenteModel?> _chargerVenteAvecDetails(
    VenteController controller,
    int venteId, {
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    VenteModel? venteComplete;
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;
      print(
        "🔄 Tentative $attempts/$maxAttempts de chargement de la vente $venteId",
      );

      try {
        await controller.loadVente(venteId);
        await Future.delayed(delay);

        venteComplete = controller.state.selectedVente;

        // ✅ Si on a des détails, on arrête
        if (venteComplete != null && venteComplete.details.isNotEmpty) {
          print("✅ Détails trouvés après $attempts tentative(s)");
          break;
        }

        // ❌ Si pas de détails, on attend un peu plus avant de réessayer
        print(
          "⏳ Pas de détails trouvés, nouvelle tentative dans ${delay.inMilliseconds}ms...",
        );
      } catch (e) {
        print("❌ Erreur lors de la tentative $attempts: $e");
      }
    }

    if (venteComplete == null || venteComplete.details.isEmpty) {
      print(
        "⚠️ Impossible de charger les détails après $maxAttempts tentatives",
      );
    }

    return venteComplete;
  }

  List<dynamic> get filteredProduits {
    final produits = context.read<ProduitController>().state.produits;
    if (searchQuery.isEmpty) return produits;
    return produits
        .where(
          (p) =>
              p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final produitState = context.watch<ProduitController>().state;
    final venteState = context.watch<VenteController>().state;
    final filteredList = filteredProduits;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Stack(
        children: [
          // Sphère décorative pour le Glassmorphism
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: darkSlate),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Nouvelle Vente",
                  style: TextStyle(
                    color: darkSlate,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  if (panier.isNotEmpty)
                    IconButton(
                      onPressed: () => _showClearCartDialog(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: "Vider le panier",
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
            body: SafeArea(
              top: false,
              child: produitState.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    )
                  : produitState.produits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 72,
                            color: softGrey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Aucun produit disponible",
                            style: TextStyle(
                              color: darkSlate,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ajoutez des produits dans l'inventaire au préalable",
                            style: TextStyle(color: softGrey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildClientInput(),
                        _buildSearchBar(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: softGrey,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Aucun produit trouvé",
                                        style: TextStyle(
                                          color: darkSlate,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    120,
                                  ),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final produit = filteredList[index];
                                    final selected = panier.containsKey(
                                      produit.id,
                                    );
                                    final quantite = panier[produit.id] ?? 0;

                                    return _buildProductCard(
                                      context,
                                      produit: produit,
                                      selected: selected,
                                      quantite: quantite,
                                      onAdd: () => ajouterProduit(
                                        produit.id,
                                        quantite + 1,
                                      ),
                                      onRemove: () => ajouterProduit(
                                        produit.id,
                                        quantite - 1,
                                      ),
                                      onDelete: () =>
                                          supprimerProduit(produit.id),
                                      onQuantityChange: (value) {
                                        final qty = int.tryParse(value) ?? 0;
                                        if (qty >= 0) {
                                          if (qty <= produit.quantite) {
                                            ajouterProduit(produit.id, qty);
                                          } else {
                                            ajouterProduit(
                                              produit.id,
                                              produit.quantite,
                                            );
                                            _showSnackbar(
                                              context,
                                              "Quantité max. de stock atteinte (${produit.quantite})",
                                              Colors.orangeAccent,
                                            );
                                          }
                                        }
                                      },
                                      controller: _getQuantityController(
                                        produit.id,
                                        quantite,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ),

          // Panier flottant en bas
          if (panier.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPanierSummary(context, venteState),
            ),
        ],
      ),
    );
  }

  Widget _buildClientInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _buildGlassContainer(
        padding: EdgeInsets.zero,
        child: TextField(
          controller: clientController,
          style: const TextStyle(color: darkSlate),
          decoration: const InputDecoration(
            labelText: "Nom de l'acheteur",
            labelStyle: TextStyle(color: softGrey, fontSize: 14),
            prefixIcon: Icon(Icons.person_outline, color: primaryGreen),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _buildGlassContainer(
        padding: EdgeInsets.zero,
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          style: const TextStyle(color: darkSlate),
          decoration: InputDecoration(
            hintText: "Rechercher un produit...",
            hintStyle: const TextStyle(color: softGrey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: softGrey),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear, color: softGrey),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required dynamic produit,
    required bool selected,
    required int quantite,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required VoidCallback onDelete,
    required Function(String) onQuantityChange,
    required TextEditingController controller,
  }) {
    final stock = produit.quantite;
    final isOutOfStock = stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Badge du stock restant
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? Colors.grey.withOpacity(0.12)
                    : (stock < 5
                          ? Colors.orange.withOpacity(0.12)
                          : primaryGreen.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stock.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isOutOfStock
                          ? softGrey
                          : (stock < 5 ? Colors.orange.shade700 : primaryGreen),
                    ),
                  ),
                  const Text(
                    "Stk",
                    style: TextStyle(
                      fontSize: 8,
                      color: softGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${produit.price.toStringAsFixed(0)} FC",
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          produit.category,
                          style: const TextStyle(
                            color: softGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!selected)
              ElevatedButton(
                onPressed: isOutOfStock ? null : onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  "Ajouter",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantite > 1) {
                        onRemove();
                      } else {
                        onDelete();
                      }
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: softGrey,
                      size: 22,
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      onChanged: onQuantityChange,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (quantite < stock) {
                        onAdd();
                      } else {
                        _showSnackbar(
                          context,
                          "Stock insuffisant ($stock disponible)",
                          Colors.orangeAccent,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: primaryGreen,
                      size: 22,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanierSummary(BuildContext context, dynamic venteState) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total du panier",
                        style: TextStyle(
                          color: softGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${total.toStringAsFixed(0)} FC",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: darkSlate.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$totalItems art.",
                          style: const TextStyle(
                            color: darkSlate,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _showClearCartDialog(context),
                        icon: const Icon(
                          Icons.delete_sweep,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          "Vider",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: venteState.saving ? null : validerVente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: venteState.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    venteState.saving
                        ? "Traitement en cours..."
                        : "Valider la vente",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearCartDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Vider le panier",
            style: TextStyle(color: darkSlate, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Voulez-vous vraiment supprimer tous les articles du panier ?",
            style: TextStyle(color: softGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler", style: TextStyle(color: softGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Vider"),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      viderPanier();
      if (!mounted) return;
      _showSnackbar(context, "Panier vidé avec succès", Colors.redAccent);
    }
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
