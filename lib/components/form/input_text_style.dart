import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class StyledTextField extends StatelessWidget {
  final String name;
  final String? hintText;
  final bool isRequired;
  final bool isVisible;
  final IconData? icon;
  final String formatter;

  const StyledTextField({
    super.key,
    required this.name,
    this.hintText,
    this.isRequired = false,
    this.isVisible = true,
    this.icon,
    this.formatter = "",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
          name: name,
          obscureText: !isVisible,
          decoration: InputDecoration(
            labelText: hintText ?? "Entrez votre texte",
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: isRequired
              ? FormBuilderValidators.compose(
                  [FormBuilderValidators.required()])
              : null,
          inputFormatters: <TextInputFormatter>[
            if (formatter == "number") FilteringTextInputFormatter.digitsOnly,
            if (formatter == "decimal")
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ]),
    );
  }
}
