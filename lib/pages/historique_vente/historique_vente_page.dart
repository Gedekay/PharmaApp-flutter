import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/domaine/facture/facture_pdf_service.dart';
import 'package:pharmacie_flutter/pages/historique_vente/historique_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoriqueVentePage extends StatefulWidget {
  const HistoriqueVentePage({super.key});

  @override
  State<HistoriqueVentePage> createState() => _HistoriqueVentePageState();
}

class _HistoriqueVentePageState extends State<HistoriqueVentePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  final ScrollController _scrollController = ScrollController();

  static const Color primaryGreen = Color(0xFF00B074);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color softGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HistoriqueController>().loadVentes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoriqueController>();

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F7F6,
      ), // Fond clair subtilement teinté vert/gris
      body: Stack(
        children: [
          // Sphère décorative pour le Glassmorphism
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.1),
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
                  "Historique des Ventes",
                  style: TextStyle(
                    color: darkSlate,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                      color: _showFilters ? primaryGreen : darkSlate,
                    ),
                    tooltip: _showFilters
                        ? "Masquer les filtres"
                        : "Afficher les filtres",
                  ),
                  IconButton(
                    onPressed: () {
                      controller.loadVentes();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Actualisation en cours..."),
                          duration: Duration(seconds: 1),
                          backgroundColor: primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: darkSlate),
                    tooltip: "Actualiser",
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
            body: SafeArea(top: false, child: _buildBody(context, controller)),
          ),
        ],
      ),
      floatingActionButton: controller.filteredVentes.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, HistoriqueController controller) {
    if (controller.loading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (controller.error != null) {
      return Center(
        child: _buildGlassContainer(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                controller.error!,
                style: const TextStyle(
                  color: darkSlate,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.loadVentes(),
                icon: const Icon(Icons.refresh),
                label: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.ventes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 72, color: softGrey),
            const SizedBox(height: 24),
            const Text(
              "Aucune vente effectuée",
              style: TextStyle(
                color: darkSlate,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Les ventes apparaîtront ici une fois enregistrées",
              style: TextStyle(color: softGrey),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Retour"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(context, controller),
        if (_showFilters) _buildFilterWidget(context, controller),
        _buildStatsWidget(context, controller),
        Expanded(
          child: controller.filteredVentes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: softGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucun résultat trouvé",
                        style: TextStyle(
                          color: darkSlate,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Aucune vente ne correspond à vos critères",
                        style: TextStyle(color: softGrey),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: const BorderSide(color: primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          controller.clearFilters();
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text("Effacer les filtres"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryGreen,
                  backgroundColor: Colors.white,
                  onRefresh: () => controller.loadVentes(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: controller.filteredVentes.length,
                    itemBuilder: (context, index) {
                      final vente = controller.filteredVentes[index];
                      return _buildVenteCard(context, vente);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    HistoriqueController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: _buildGlassContainer(
        padding: EdgeInsets.zero,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => controller.search(value),
          style: const TextStyle(color: darkSlate),
          decoration: InputDecoration(
            hintText: "Rechercher par client ou facture...",
            hintStyle: const TextStyle(color: softGrey),
            prefixIcon: const Icon(Icons.search, color: softGrey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.search('');
                    },
                    icon: const Icon(Icons.clear, color: softGrey),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterWidget(
    BuildContext context,
    HistoriqueController controller,
  ) {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Filtres rapides",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (controller.filterType != 'all' ||
                  controller.startDate != null)
                TextButton(
                  onPressed: controller.clearFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text("Tout effacer"),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                label: "Toutes",
                selected:
                    controller.filterType == 'all' &&
                    controller.startDate == null,
                onSelected: () => controller.filterByType('all'),
              ),
              _buildChip(
                label: "Aujourd'hui",
                selected: controller.filterType == 'today',
                onSelected: () => controller.filterByType('today'),
              ),
              _buildChip(
                label: "Cette semaine",
                selected: controller.filterType == 'week',
                onSelected: () => controller.filterByType('week'),
              ),
              _buildChip(
                label: "Ce mois",
                selected: controller.filterType == 'month',
                onSelected: () => controller.filterByType('month'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkSlate,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _selectDateRange(context, controller),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    controller.startDate != null && controller.endDate != null
                        ? "${DateFormat('dd/MM/yyyy').format(controller.startDate!)} - ${DateFormat('dd/MM/yyyy').format(controller.endDate!)}"
                        : "Période personnalisée",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (controller.startDate != null ||
                  controller.endDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  tooltip: "Effacer les filtres",
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: primaryGreen.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? primaryGreen : softGrey,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? primaryGreen : Colors.grey.shade300,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }

  Widget _buildStatsWidget(
    BuildContext context,
    HistoriqueController controller,
  ) {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.receipt_long,
            label: "Ventes",
            value: controller.totalVentes.toString(),
            color: primaryGreen,
          ),
          _buildStatItem(
            icon: Icons.shopping_cart,
            label: "Articles",
            value: controller.totalArticles.toString(),
            color: Colors.teal.shade500,
          ),
          _buildStatItem(
            icon: Icons.payments,
            label: "CA Total",
            value: "${controller.totalCA.toStringAsFixed(0)} FC",
            color: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkSlate,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: softGrey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVenteCard(BuildContext context, dynamic vente) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors
              .transparent, // Retirer la ligne de division par défaut d'ExpansionTile
        ),
        child: _buildGlassContainer(
          padding: EdgeInsets.zero,
          child: Material(
            // <--- AJOUTÉ : Donne un canevas pour l'effet d'encre (InkWell/ListTile)
            color: Colors
                .transparent, // Conserve le fond de votre conteneur en verre
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(
              20,
            ), // Assurez-vous d'avoir le même arrondi que votre contenant verre
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: primaryGreen.withOpacity(0.1),
                child: Text(
                  "#${vente.id}",
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                vente.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Facture: ${vente.factureNumero}",
                      style: const TextStyle(color: softGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vente.createdAt != null
                          ? dateFormat.format(vente.createdAt!)
                          : 'Date inconnue',
                      style: const TextStyle(color: softGrey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${vente.total.toStringAsFixed(0)} FC",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${vente.details.length} article${vente.details.length > 1 ? 's' : ''}",
                    style: const TextStyle(color: softGrey, fontSize: 11),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      ...vente.details.map<Widget>((detail) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "${detail.quantite}x",
                                  style: const TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail.produit.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: darkSlate,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "P.U. ${detail.price.toStringAsFixed(0)} FC",
                                      style: const TextStyle(
                                        color: softGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${(detail.price * detail.quantite).toStringAsFixed(0)} FC",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkSlate,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _printFacture(context, vente),
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text("Imprimer"),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _shareFacture(context, vente),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text("Partager"),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printFacture(BuildContext context, dynamic vente) async {
    _showProgressDialog(context);
    try {
      await FacturePdfService.imprimerAvecDialogue(context, vente);
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(context, "Facture envoyée à l'impression", primaryGreen);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(
        context,
        "Erreur d'impression: ${e.toString()}",
        Colors.redAccent,
      );
    }
  }

  Future<void> _shareFacture(BuildContext context, dynamic vente) async {
    _showProgressDialog(context);
    try {
      await FacturePdfService.partagerPdf(vente);
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(context, "PDF partagé avec succès", primaryGreen);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(
        context,
        "Erreur de partage: ${e.toString()}",
        Colors.redAccent,
      );
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
        content: Text(text),
        backgroundColor: color,
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
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

  Future<void> _selectDateRange(
    BuildContext context,
    HistoriqueController controller,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          controller.startDate != null && controller.endDate != null
          ? DateTimeRange(
              start: controller.startDate!,
              end: controller.endDate!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkSlate,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      controller.filterByDate(picked.start, picked.end);
    }
  }
}
