import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class CustomRadioButton extends StatefulWidget {
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final String label;

  CustomRadioButton({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value == widget.groupValue;

    return GestureDetector(
      onTap: () {
        try {
          debugPrint("Tapped on ${widget.value}");
          widget.onChanged(widget.value);
        } catch (e) {
          debugPrint('Error in onChanged: ${widget.value}');
        }
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: darkGreyColor,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: lightGreenColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(
            width: 9,
          ),
          Text(
            widget.label,
            style: regularTextStyle.copyWith(
              color: blackColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
