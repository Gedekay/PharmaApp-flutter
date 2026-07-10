import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/core/theme/theme_extension.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: Center(
        child: Container(
          color: colors.background,
          child: Text("hello word", style: TextStyle(color: colors.text)),
        ),
      ),
    );
  }
}
