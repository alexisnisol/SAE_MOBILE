
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../models/viewmodel/authentication_service.dart';
import '../form/input_text_style.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StyledTextField(name: "name", hintText: "Nom", isRequired: true, icon: Icons.person),
          SizedBox(height: 16),
          StyledTextField(name: "email", hintText: "Email", isRequired: true, icon: Icons.email),
          SizedBox(height: 16),
          StyledTextField(name: "password", hintText: "Mot de passe", isRequired: true, isVisible: false, icon: Icons.lock),
          SizedBox(height: 16),
          StyledTextField(name: "confirm_password", hintText: "Confirmer le mot de passe", isRequired: true, isVisible: false, icon: Icons.lock),
          SizedBox(height: 16),
          FormBuilderCheckbox(
            name: 'accept_terms',
            title: Text("J'accepte les conditions"),
            validator: FormBuilderValidators.required(
              errorText: "Vous devez accepter les conditions pour continuer",
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.saveAndValidate()) {
                if (_formKey.currentState!.value['password'] != _formKey.currentState!.value['confirm_password']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Les mots de passe ne correspondent pas")),
                  );
                  return;
                }
                final data = _formKey.currentState?.value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Données : " + data.toString())),
                );

                context.read<AuthenticationService>().register(
                  UserModel.createUser(
                      _formKey.currentState!.fields['name']!.value,
                    _formKey.currentState!.fields['email']!.value
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff587c60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("S'inscrire", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}