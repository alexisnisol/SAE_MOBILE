import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sae_mobile/components/auth/auth_welcome.dart';
import 'package:sae_mobile/components/auth/register_form.dart';

import '../../components/auth/switch_auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AuthWelcomeText(isRegister: true),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                  padding: const EdgeInsets.all(16.0), child: RegisterForm()),
            ),
          ),
          AuthButton(isRegister: true),
        ],
      ),
    ));
  }
}
