import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class CustomTextform extends StatefulWidget {
  final String formTitle;
  final String hintText;
  final bool obscureText;
  final TextInputType textInputType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextform({
    super.key,
    required this.formTitle,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextform> createState() => _CustomTextformState();
}

class _CustomTextformState extends State<CustomTextform> {
  //Form Focus Color
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = _isFocused ? lightGreenColor : blackColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.formTitle,
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: TextFormField(
            validator: widget.validator,
            keyboardType: widget.textInputType,
            controller: widget.controller,
            focusNode: _focusNode,
            style: regularTextStyle.copyWith(
              color: blackColor,
              fontSize: 15,
            ),
            obscureText: widget.obscureText,
            cursorHeight: 20,
            cursorColor: lightGreenColor,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: regularTextStyle.copyWith(
                color: lightGreyColor,
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
