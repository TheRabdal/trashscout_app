import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class DateOfBirthForm extends StatefulWidget {
  final TextEditingController dateController;

  const DateOfBirthForm({required this.dateController});

  @override
  State<DateOfBirthForm> createState() => _DateOfBirthFormState();
}

class _DateOfBirthFormState extends State<DateOfBirthForm> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      setState(() {
        widget.dateController.text = picked.toString().split(" ")[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        Text(
          'Silahkan diisi tanggal lahir anda',
          style: regularTextStyle.copyWith(
            color: lightGreyColor,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: blackColor,
              width: 1,
            ),
          ),
          child: TextField(
            style: regularTextStyle.copyWith(
              color: blackColor,
            ),
            controller: widget.dateController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              hintText: 'Pilih Tanggal lahir anda',
              hintStyle: regularTextStyle.copyWith(
                color: lightGreyColor,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.calendar_today,
                size: 24,
                color: lightGreyColor,
              ),
            ),
            readOnly: true,
            onTap: () {
              _selectDate(context);
            },
          ),
        ),
      ],
    );
  }
}
