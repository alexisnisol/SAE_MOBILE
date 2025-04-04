import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../models/helper/auth_helper.dart';
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
          StyledTextField(
              name: "name",
              hintText: "Nom",
              isRequired: true,
              icon: Icons.person),
          SizedBox(height: 16),
          StyledTextField(
              name: "email",
              hintText: "Email",
              isRequired: true,
              icon: Icons.email),
          SizedBox(height: 16),
          StyledTextField(
              name: "password",
              hintText: "Mot de passe",
              isRequired: true,
              isVisible: false,
              icon: Icons.lock),
          SizedBox(height: 16),
          StyledTextField(
              name: "confirm_password",
              hintText: "Confirmer le mot de passe",
              isRequired: true,
              isVisible: false,
              icon: Icons.lock),
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
            onPressed: () async {
              if (_formKey.currentState!.saveAndValidate()) {
                final name = _formKey.currentState!.value['name'];
                final email = _formKey.currentState!.value['email'];
                final password = _formKey.currentState!.value['password'];
                final confirmPassword =
                    _formKey.currentState!.value['confirm_password'];

                if (!checkName(context, name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Le nom doit contenir uniquement des lettres")),
                  );
                  return;
                }

                if (!checkEmail(context, email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("L'email n'est pas valide")),
                  );
                  return;
                }

                if (!checkPasswordMatch(context, password, confirmPassword)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Les mots de passe ne correspondent pas")),
                  );
                  return;
                }

                if (!checkPassword(context, password)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Le mot de passe doit contenir au moins 8 caractères, une lettre et un chiffre")),
                  );
                  return;
                }

                try {
                  await AuthHelper.signUp(name, email, password);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Inscription réussie")),
                  );
                  context.go('/login');
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff587c60),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("S'inscrire",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static checkPasswordMatch(
      BuildContext context, String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static checkEmail(BuildContext context, String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static checkPassword(BuildContext context, String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  static checkName(BuildContext context, String name) {
    final nameRegex = RegExp(r'^[a-zA-Z ]+$');
    return nameRegex.hasMatch(name);
  }
}
