import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/components/auth/circle_logo.dart';
import 'package:sae_mobile/components/auth/login_form.dart';
import '../../components/auth/auth_welcome.dart';
import '../../components/auth/switch_auth_button.dart';
import '../../components/form/input_text_style.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthWelcomeText(isRegister: false),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LoginForm()
                    ),
                  ),
                ),
                AuthButton(isRegister: false),
              ],
            ),
          )
    );
  }
}