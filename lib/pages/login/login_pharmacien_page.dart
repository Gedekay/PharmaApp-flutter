import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/core/theme/theme_extension.dart';
import 'package:pharmacie_flutter/pages/homa-page.dart';
import 'package:pharmacie_flutter/pages/login/login_ctr.dart';
import 'package:pharmacie_flutter/pages/login/login_state.dart';
import 'package:provider/provider.dart'; // Assure-toi que le chemin vers ton theme_extension.dart est correct

class LoginPharmacienPage extends StatefulWidget {
  const LoginPharmacienPage({super.key});

  @override
  State<LoginPharmacienPage> createState() => _LoginPharmacienPageState();
}

class _LoginPharmacienPageState extends State<LoginPharmacienPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<AuthPharmacienCtrl>();
    final appColors = Theme.of(context).extension<AppColors>()!;

    // Appel de la méthode de connexion
    await ctrl.login(_nameController.text.trim(), _phoneController.text.trim());

    // Vérification du résultat de l'état
    if (mounted) {
      if (ctrl.state.status == AuthStatus.success) {
        // Message de bienvenue avec ton vert success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bienvenue, Dr. ${ctrl.state.data?.pharmacien?.name} !',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: appColors.success,
          ),
        );
        // Redirection vers l'accueil de l'application
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (ctrl.state.status == AuthStatus.error) {
        // Affichage de l'erreur renvoyée avec ta couleur error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ctrl.state.errorMessage ?? 'Une erreur est survenue'),
            backgroundColor: appColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écoute de l'état pour adapter l'UI
    final authState = context.watch<AuthPharmacienCtrl>().state;
    final isLoading = authState.status == AuthStatus.loading;

    // Récupération de ton thème personnalisé
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor:
          appColors.background, // Utilise le fond dynamique du thème
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- IMAGE PHARMA ---
                  Center(
                    child: Image.asset(
                      'assets/images/pharma.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Text(
                    'Pharma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: appColors.textSecondary, // Gris text doux du thème
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Connectez-vous avec vos identifiants.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: appColors.textSecondary, // Gris text doux du thème
                    ),
                  ),
                  const SizedBox(height: 36),

                  // --- CHAMP : NOM DE FAMILLE ---
                  Text(
                    'Nom de famille',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appColors.title, // S'adapte au mode clair/sombre
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.name,
                    style: TextStyle(color: appColors.text),
                    decoration: InputDecoration(
                      hintText: 'Ex: Lubanda',
                      hintStyle: TextStyle(
                        color: appColors.textSecondary.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: appColors.primary,
                      ),
                      filled: true,
                      fillColor: appColors.primary.withOpacity(
                        0.06,
                      ), // Très léger voile vert médical pro
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- CHAMP : NUMÉRO DE TÉLÉPHONE ---
                  Text(
                    'Numéro de téléphone',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appColors.title,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: appColors.text),
                    decoration: InputDecoration(
                      hintText: 'Ex: +243...',
                      hintStyle: TextStyle(
                        color: appColors.textSecondary.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: appColors.primary,
                      ),
                      filled: true,
                      fillColor: appColors.primary.withOpacity(
                        0.06,
                      ), // Cohérence visuelle
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: appColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: appColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- BOUTON DE CONNEXION ---
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          appColors.primary, // Vert Sarcelle (0xFF00796B)
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: appColors.disabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
