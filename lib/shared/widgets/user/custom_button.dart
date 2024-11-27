import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final void Function() onPressed;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: darkGreenColor,
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: semiBoldTextStyle.copyWith(
          fontSize: 24,
        ),
      ),
      child: Text(
        buttonText,
        style: semiBoldTextStyle.copyWith(
          color: whiteColor,
        ),
      ),
    );
  }
}
