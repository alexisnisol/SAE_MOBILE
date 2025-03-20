import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
      appBar: AppBar(
        title: const Text("Inscription"),
      ),
      body: Center(
        child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FormBuilderTextField(
                  name: 'Username',
                  decoration: const InputDecoration(labelText: 'Username:'),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                FormBuilderTextField(
                  name: 'Email',
                  decoration: const InputDecoration(labelText: 'Email:'),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                FormBuilderTextField(
                  name: 'Password',
                  decoration: const InputDecoration(labelText: 'Password:'),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      backgroundColor: Colors.lightBlue,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        print(_formKey.currentState!.value);
                      }
                    },
                    child: const Text("S'inscrire"))
              ],
            )
        ),
      ),
    );
  }

}