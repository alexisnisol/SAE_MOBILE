import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../form/input_text_style.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StyledTextField(name: "email", hintText: "Email", isRequired: true, icon: Icons.email),
          SizedBox(height: 16),
          StyledTextField(name: "password", hintText: "Mot de passe", isRequired: true, isVisible: false, icon: Icons.lock),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final data = _formKey.currentState?.value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Données : \$data")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff587c60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Se connecter", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}