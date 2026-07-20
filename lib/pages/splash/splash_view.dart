import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/pages/dashboard/dashboard_page.dart';
import 'package:provider/provider.dart';
import 'package:pharmacie_flutter/core/theme/theme_extension.dart';
import 'package:pharmacie_flutter/pages/login/login_pharmacien_page.dart';
import 'package:pharmacie_flutter/pages/login/login_ctr.dart';

class PharmaSplashView extends StatefulWidget {
  const PharmaSplashView({super.key});

  @override
  State<PharmaSplashView> createState() => _PharmaSplashViewState();
}

class _PharmaSplashViewState extends State<PharmaSplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authCtrl = context.read<AuthPharmacienCtrl>();
    final bool isConnected = await authCtrl.checkAutoLogin();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isConnected ? const DashboardPage() : const LoginPharmacienPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appColors.primary.withOpacity(0.2),
                  appColors.primary,
                  appColors.secondary,
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.15,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 25,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: GlassCard(
                rotationController: _rotationController,
                appColors: appColors,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final AnimationController rotationController;
  final AppColors appColors;

  const GlassCard({
    super.key,
    required this.rotationController,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        color: Colors.white.withOpacity(0.05),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: rotationController,
                    child: Image.asset(
                      'assets/images/pharma.png',
                      width: 170,
                      height: 170,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_pharmacy_rounded,
                          size: 120,
                          color: Colors.white.withOpacity(0.9),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Bazar Pharma',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Votre santé, notre priorité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
