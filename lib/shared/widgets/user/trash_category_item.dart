import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class TrashCategoryItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onDeselected;

  const TrashCategoryItem({
    required this.title,
    required this.isSelected,
    required this.onDeselected,
    required this.onSelected,
  });

  @override
  State<TrashCategoryItem> createState() => _TrashCategoryItemState();
}

class _TrashCategoryItemState extends State<TrashCategoryItem> {
  void _handleTap() {
    if (widget.isSelected) {
      widget.onDeselected(widget.title);
    } else {
      widget.onSelected(widget.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected ? lightGreenColor : darkGreenColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.title,
              style: regularTextStyle.copyWith(
                color: whiteColor,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
