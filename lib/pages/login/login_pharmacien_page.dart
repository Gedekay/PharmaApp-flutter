import 'dart:ui'; // Requis pour ImageFilter (effet de flou)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacie_flutter/pages/dashboard/dashboard_page.dart';
import 'package:pharmacie_flutter/pages/login/login_ctr.dart';
import 'package:pharmacie_flutter/pages/login/login_state.dart';
import 'package:provider/provider.dart';

class LoginPharmacienPage extends StatefulWidget {
  const LoginPharmacienPage({super.key});

  @override
  State<LoginPharmacienPage> createState() => _LoginPharmacienPageState();
}

class _LoginPharmacienPageState extends State<LoginPharmacienPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePhone = true;
  bool _rememberMe = false;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<AuthPharmacienCtrl>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    await ctrl.login(name, phone);

    if (!mounted) return;

    if (ctrl.state.status == AuthStatus.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Bienvenue, Dr. ${ctrl.state.data?.pharmacien?.name ?? name} !',
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (ctrl.state.status == AuthStatus.error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ctrl.state.errorMessage ??
                'Identifiants invalides ou erreur serveur',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthPharmacienCtrl>().state;
    final isLoading = authState.status == AuthStatus.loading;

    // Couleurs adaptées pour le thème clair
    const textDarkColor = Color(0xFF1E293B); // Slate 800 (très lisible)
    const textMutedColor = Color(0xFF64748B); // Slate 500

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fond clair et doux (Slate 50)
      body: Stack(
        children: [
          // 1. ANIME BACKGROUND - Orbes vertes et émeraudes animées en arrière-plan
          if (_animationController != null)
            AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                final animValue = _animationController!.value;
                return Stack(
                  children: [
                    // Orbe Verte/Émeraude supérieure gauche
                    Positioned(
                      top: -100 + (animValue * 50),
                      left: -50 + (animValue * 30),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(
                            0.18,
                          ), // Vert principal de l'app
                        ),
                      ),
                    ),
                    // Orbe Menthe/Teal inférieure droite
                    Positioned(
                      bottom: -80 - (animValue * 40),
                      right: -60 - (animValue * 30),
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.shade300.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          // Filtre global de flou pour mélanger doucement les orbes
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: const SizedBox.shrink(),
            ),
          ),

          // 2. CONTENU PRINCIPAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 1000),
                        scale: isLoading ? 0.9 : 1.0,
                        child: Image.asset(
                          'assets/images/pharma.png',
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.local_pharmacy_rounded,
                              size: 120,
                              color: theme.primaryColor,
                            );
                          },
                        ),
                      ),

                      Text(
                        'Bazar Pharma',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textDarkColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              // Blanc très transparent pour l'effet de verre clair
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  0.8,
                                ), // Bordure brillante claire
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.06,
                                  ), // Ombre très douce
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Connexion',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Connectez-vous à votre espace professionnel',
                                  style: TextStyle(
                                    color: textMutedColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Champ : Nom complet
                                _buildNameField(
                                  isLoading,
                                  theme,
                                  textDarkColor,
                                ),
                                const SizedBox(height: 20),

                                // Champ : Téléphone
                                _buildPhoneField(
                                  isLoading,
                                  theme,
                                  textDarkColor,
                                ),
                                const SizedBox(height: 16),

                                // Options (Se souvenir de moi)
                                _buildOptionsRow(theme, textMutedColor),
                                const SizedBox(height: 24),

                                // Bouton Soumettre
                                _buildLoginButton(isLoading, theme),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pied de page
                      _buildFooter(theme, textMutedColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Input adaptation pour thème clair en verre
  InputDecoration _buildGlassInputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: prefixIcon,
      prefixIconColor: const Color(0xFF64748B),
      suffixIcon: suffixIcon,
      suffixIconColor: const Color(0xFF64748B),
      filled: true,
      fillColor: Colors.white.withOpacity(
        0.5,
      ), // Légère opacité blanche à l'intérieur du champ
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildNameField(bool isLoading, ThemeData theme, Color textDarkColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom complet *',
          style: TextStyle(
            color: textDarkColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          enabled: !isLoading,
          style: TextStyle(color: textDarkColor),
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: _buildGlassInputDecoration(
            hintText: 'Entrez votre nom complet',
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            if (value.trim().length < 2) {
              return 'Le nom doit contenir au moins 2 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(
    bool isLoading,
    ThemeData theme,
    Color textDarkColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone *',
          style: TextStyle(
            color: textDarkColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          enabled: !isLoading,
          style: TextStyle(color: textDarkColor),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          decoration: _buildGlassInputDecoration(
            hintText: 'Ex: 243812345678',
            prefixIcon: const Icon(Icons.phone_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePhone = !_obscurePhone;
                });
              },
              icon: Icon(
                _obscurePhone
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          obscureText: _obscurePhone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre numéro de téléphone';
            }
            if (value.trim().length < 8) {
              return 'Le numéro doit contenir au moins 8 chiffres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsRow(ThemeData theme, Color textMutedColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: theme.primaryColor,
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: textMutedColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Se souvenir de moi',
                  style: TextStyle(color: textMutedColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: textMutedColor),
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading, ThemeData theme) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor, // Vert de l'application
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.primaryColor.withOpacity(0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Connexion en cours...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Se connecter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, Color textMutedColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Vous n'avez pas de compte ?",
              style: TextStyle(color: textMutedColor, fontSize: 13),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
              child: const Text(
                "Contactez l'admin",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Connexion sécurisée • Pharmacie',
          style: TextStyle(
            color: textMutedColor.withOpacity(0.6),
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: TextStyle(color: textMutedColor.withOpacity(0.6), fontSize: 9),
        ),
      ],
    );
  }
}
