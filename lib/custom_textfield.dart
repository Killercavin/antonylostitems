import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final Icon? icon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    required this.isPassword,
    required this.controller,
    this.icon,
    this.validator,
    required this.hintText,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      controller: widget.controller,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        fillColor: const Color(0xfff3f3f4),
        filled: true,
        prefixIcon: widget.icon,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}
