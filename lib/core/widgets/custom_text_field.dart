import 'package:flutter/material.dart';

/// A reusable standard text field with an outline border.
class CustomTextField extends StatelessWidget {
  /// The controller for editing the text.
  final TextEditingController controller;

  /// The label text to display above/inside the field.
  final String labelText;

  /// Optional prefix icon to display inside the text field.
  final Widget? prefixIcon;

  /// Optional suffix icon to display inside the text field (e.g. password visibility toggle).
  final Widget? suffixIcon;

  /// Whether to obscure the text (e.g. for password inputs). Defaults to false.
  final bool obscureText;

  /// Optional input validator.
  final FormFieldValidator<String>? validator;

  /// Optional callback for when the user submits their input.
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
