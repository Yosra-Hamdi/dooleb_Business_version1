import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }
}