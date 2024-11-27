import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_radio_button.dart';

class GenderForm extends StatefulWidget {
  final ValueChanged<String> onChanged;

  GenderForm({required this.onChanged});

  @override
  _GenderFormState createState() => _GenderFormState();
}

class _GenderFormState extends State<GenderForm> {
  String _selectedGender = '';

  void _handleRadioValueChange(String value) {
    setState(() {
      _selectedGender = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        Text(
          'Silahkan pilih jenis kelamin anda',
          style: regularTextStyle.copyWith(
            color: lightGreyColor,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            CustomRadioButton(
              value: 'Pria',
              groupValue: _selectedGender,
              onChanged: _handleRadioValueChange,
              label: 'Pria',
            ),
            SizedBox(
              width: 30,
            ),
            CustomRadioButton(
              value: 'Wanita',
              groupValue: _selectedGender,
              onChanged: _handleRadioValueChange,
              label: 'Wanita',
            ),
          ],
        ),
      ],
    );
  }
}
