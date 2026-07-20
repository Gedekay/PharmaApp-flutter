import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/pages/historique_vente/historique_vente_page.dart';
import 'package:pharmacie_flutter/pages/vente/vente_page.dart';
import 'package:provider/provider.dart';
import 'package:pharmacie_flutter/pages/dashboard/dashboard_controller.dart';
import 'package:pharmacie_flutter/pages/login/login_ctr.dart';
import 'package:pharmacie_flutter/pages/login/login_pharmacien_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _bgAnimationController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshData());

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController?.dispose();
    super.dispose();
  }

  void _refreshData() {
    context.read<DashboardController>().loadDashboard();
  }

  Future<void> _logout() async {
    const textDarkColor = Color(0xFF1E293B);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Déconnexion",
          style: TextStyle(color: textDarkColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Voulez-vous vraiment vous déconnecter de votre espace ?",
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Déconnecter",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = context.read<AuthPharmacienCtrl>();
      await auth.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPharmacienPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final state = dashboard.state;
    final auth = context.watch<AuthPharmacienCtrl>();
    final theme = Theme.of(context);

    const textDarkColor = Color(0xFF1E293B);
    const textMutedColor = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white.withOpacity(0.4),
        toolbarHeight: 70,

        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),

        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.primaryColor.withOpacity(0.15),
              child: Text(
                auth.fullName.isNotEmpty ? auth.fullName[0].toUpperCase() : 'P',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bonjour,",
                    style: TextStyle(
                      fontSize: 12,
                      color: textMutedColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    auth.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _buildAppBarButton(
            icon: Icons.history_rounded,
            tooltip: "Historique des ventes",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoriqueVentePage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildAppBarButton(
            icon: Icons.refresh_rounded,
            tooltip: "Actualiser",
            onPressed: _refreshData,
          ),
          const SizedBox(width: 4),
          Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: textDarkColor,
                  size: 20,
                ),
              ),
              onSelected: (value) {
                if (value == "logout") _logout();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Déconnexion",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          if (_bgAnimationController != null)
            AnimatedBuilder(
              animation: _bgAnimationController!,
              builder: (context, child) {
                final animValue = _bgAnimationController!.value;
                return Stack(
                  children: [
                    Positioned(
                      top: 40 + (animValue * 60),
                      right: -80 + (animValue * 40),
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100 - (animValue * 70),
                      left: -100 + (animValue * 50),
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            16,
                            65,
                            60,
                          ).withOpacity(0.20),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 300 - (animValue * 50),
                      left: -50 + (animValue * 40),
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            16,
                            65,
                            60,
                          ).withOpacity(0.20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox.shrink(),
            ),
          ),

          SafeArea(
            child: Builder(
              builder: (context) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.dashboard == null) {
                  return Center(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.8, end: 1.0),
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 72,
                              color: theme.primaryColor.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.error ?? "Aucune donnée disponible",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: textDarkColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text("Réessayer"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final dash = state.dashboard!;

                return RefreshIndicator(
                  onRefresh: () async => _refreshData(),
                  color: theme.primaryColor,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    children: [
                      // GRILLE STATISTIQUES EN GLASSMORPHISM
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        children: [
                          _buildStatCard(
                            context,
                            title: "Produits",
                            value: "${dash.produits}",
                            icon: Icons.medication_rounded,
                            iconColor: theme.primaryColor,
                            index: 0,
                          ),
                          _buildStatCard(
                            context,
                            title: "Ventes",
                            value: "${dash.ventes}",
                            icon: Icons.shopping_basket_rounded,
                            iconColor: Colors.blue.shade600,
                            index: 1,
                          ),
                          _buildStatCard(
                            context,
                            title: "Chiffre d'affaires",
                            value: "${dash.ca.toStringAsFixed(0)} FC",
                            icon: Icons.insights_rounded,
                            iconColor: Colors.teal.shade600,
                            index: 2,
                          ),
                          _buildStatCard(
                            context,
                            title: "Stock faible",
                            value: "${dash.stockFaible}",
                            icon: Icons.warning_amber_rounded,
                            iconColor: Colors.orange.shade700,
                            index: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // SECTION HEADER : ALERTES STOCK
                      Row(
                        children: [
                          Icon(
                            Icons.notification_important_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Alertes Stock (${dash.stockFaible})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textDarkColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // LISTE ALERTES PRODUITS
                      if (dash.stockFaibleList.isEmpty)
                        _buildEmptyAlertCard()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dash.stockFaibleList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = dash.stockFaibleList[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 80),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 15 * (1.0 - value)),
                                  child: _buildProductCard(
                                    context,
                                    p,
                                    theme,
                                    textDarkColor,
                                    textMutedColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VentePage()),
              ).then((_) => _refreshData());
            },
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text(
              "Nouvelle Vente",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - val)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), // Verre clair
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Icon(icon, color: iconColor, size: 20),
                        ],
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    dynamic product,
    ThemeData theme,
    Color textDarkColor,
    Color textMutedColor,
  ) {
    final isCritical = (product.quantite ?? 0) <= 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCritical ? Colors.red.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  product.quantite.toString(),
                  style: TextStyle(
                    color: isCritical
                        ? Colors.red.shade700
                        : Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${product.category} • Rayon ${product.emplacement}",
                      style: TextStyle(color: textMutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Text(
                "${product.price.toStringAsFixed(0)} FC",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.8)),
          ),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyAlertCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.7)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 36,
            ),
            SizedBox(height: 10),
            Text(
              "Tous les produits ont un stock suffisant",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
