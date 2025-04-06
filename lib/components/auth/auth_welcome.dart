import 'package:flutter/material.dart';

import 'circle_logo.dart';

class AuthWelcomeText extends StatelessWidget {
  final bool isRegister;

  const AuthWelcomeText({super.key, required this.isRegister});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleLogo(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: const Text(
            "Bienvenue chez Taste&Tell !",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            isRegister
                ? "Inscrivez-vous maintenant"
                : "Connectez-vous maintenant",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
