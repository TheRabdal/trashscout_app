import 'package:flutter/material.dart';
import 'package:trash_scout/services/api_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class ProvincesRegenciesDropdown extends StatefulWidget {
  final ValueChanged<Map<String, String>> onProvinceChanged;
  final ValueChanged<Map<String, String>> onRegencyChanged;

  ProvincesRegenciesDropdown({
    required this.onProvinceChanged,
    required this.onRegencyChanged,
  });

  @override
  _ProvincesRegenciesDropdownState createState() =>
      _ProvincesRegenciesDropdownState();
}

class _ProvincesRegenciesDropdownState
    extends State<ProvincesRegenciesDropdown> {
  List<dynamic> _provinces = [];
  List<dynamic> _regencies = [];
  String? _selectedProvinceId;
  String? _selectedProvinceName;
  String? _selectedRegencyId;
  String? _selectedRegencyName;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final provinces = await ApiService().getProvinces();
      if (mounted) {
        setState(() {
          _provinces = provinces;
        });
      }
    } catch (e) {
      SnackBar(content: Text('Gagal Memuat Provinsi'));
    }
  }

  Future<void> _fetchRegencies(String provinceId) async {
    if (mounted) {
      setState(() {
        _regencies = [];
        _selectedRegencyId = null;
        _selectedRegencyName = null;
      });
    }

    try {
      final regencies = await ApiService().getRegencies(provinceId);
      if (mounted) {
        setState(() {
          _regencies = regencies;
        });
      }
    } catch (e) {
      SnackBar(content: Text('Gagal Memuat Kabupaten'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Provinsi',
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 4),
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
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: InputBorder.none,
            ),
            hint: Text(
              'Pilih Provinsi',
              style: regularTextStyle.copyWith(
                fontSize: 15,
                color: lightGreyColor,
              ),
            ),
            style: regularTextStyle.copyWith(
              color: blackColor,
              fontSize: 15,
            ),
            initialValue: _selectedProvinceId,
            onChanged: (String? newValue) {
              setState(() {
                _selectedProvinceId = newValue;
                final province = _provinces.firstWhere(
                  (province) => province['id'].toString() == newValue,
                  orElse: () => null,
                );
                _selectedProvinceName =
                    province != null && province['name'] != null
                        ? province['name']
                        : '';
                if (newValue != null) {
                  _fetchRegencies(newValue);
                  widget.onProvinceChanged(
                      {'id': newValue, 'name': _selectedProvinceName ?? ''});
                }
              });
            },
            items: _provinces.isEmpty
                ? [DropdownMenuItem(child: Text('Memuat data Provinsi...'))]
                : _provinces.map<DropdownMenuItem<String>>((dynamic province) {
                    return DropdownMenuItem<String>(
                      value: province['id'].toString(),
                      child: Text(province['name']),
                    );
                  }).toList(),
          ),
        ),
        SizedBox(height: 25),
        Text(
          'Pilih Kabupaten',
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 4),
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
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
            hint: Text(
              'Pilih Kabupaten',
              style: regularTextStyle.copyWith(
                fontSize: 15,
                color: lightGreyColor,
              ),
            ),
            style: regularTextStyle.copyWith(
              color: blackColor,
              fontSize: 15,
            ),
            initialValue: _selectedRegencyId,
            onChanged: (String? newValue) {
              try {
                setState(() {
                  _selectedRegencyId = newValue;
                  final regency = _regencies.firstWhere(
                    (regency) => regency['id'].toString() == newValue,
                    orElse: () => null,
                  );
                  _selectedRegencyName =
                      regency != null && regency['name'] != null
                          ? regency['name']
                          : '';
                  if (newValue != null) {
                    widget.onRegencyChanged(
                        {'id': newValue, 'name': _selectedRegencyName ?? ''});
                  }
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Gagal memilih kabupaten. Silakan coba lagi.')),
                );
              }
            },
            items: _regencies.isEmpty
                ? [
                    DropdownMenuItem(
                      child: Text(
                        'Pilih Provinsi Dahulu',
                        style: regularTextStyle.copyWith(
                          color: redColor,
                        ),
                      ),
                    ),
                  ]
                : _regencies.map<DropdownMenuItem<String>>(
                    (dynamic regency) {
                      return DropdownMenuItem<String>(
                        value: regency['id'].toString(),
                        child: Text(regency['name']),
                      );
                    },
                  ).toList(),
          ),
        ),
      ],
    );
  }
}
