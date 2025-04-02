import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthButton extends StatelessWidget {
  final bool isRegister;

  const AuthButton({super.key, required this.isRegister});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
      context.go(isRegister ? '/login' : '/register');
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: const Color(0xff587c60))),
    ),
    child: Text(isRegister ? "Se Connecter" : "S'Inscrire", style: TextStyle(fontSize: 16, color: const Color(0xff587c60))),
    );
  }
}