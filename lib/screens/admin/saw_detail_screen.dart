import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:flutter/services.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? color;
  const SectionCard(
      {required this.title, required this.child, this.color, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: semiBoldTextStyle.copyWith(fontSize: 17)),
            SizedBox(height: 4),
            Divider(thickness: 1, color: lightGreyColor),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class SawDetailScreen extends StatefulWidget {
  @override
  State<SawDetailScreen> createState() => _SawDetailScreenState();
}

class _SawDetailScreenState extends State<SawDetailScreen> {
  // List Alternatif
  final List<TextEditingController> nameControllers =
      List.generate(5, (_) => TextEditingController());

  // Tambahan: List pilihan nama statis
  final List<String> staticNames = [
    'Andi',
    'Budi',
    'Citra',
    'Dewi',
    'Eka',
    'Lainnya...'
  ];
  // Untuk menyimpan pilihan dropdown per baris
  final String placeholderName = 'Pilih Nama Terlebih Dahulu';
  final List<String?> selectedNames =
      List.generate(5, (_) => 'Pilih Nama Terlebih Dahulu');
  // Untuk menandai apakah input manual aktif per baris
  final List<bool> isManualInput = List.generate(5, (_) => false);

  // Kriteria rating controller: [user][kriteria]
  final List<List<TextEditingController>> criteriaControllers = List.generate(
    5,
    (_) => List.generate(3, (_) => TextEditingController()),
  );

  // Bobot Preferensi (bisa diedit manual kalau ingin dinamis)
  final List<double> bobot = [0.5, 0.3, 0.2]; // C1, C2, C3

  List<Map<String, dynamic>> userList = [];
  bool _isLoadingUser = true;

  // State untuk hasil perhitungan
  List<List<double>> lastNormalisasi =
      List.generate(5, (_) => List.filled(3, 0.0));
  List<Map<String, dynamic>> lastResult = [];
  List<List<double>> lastMatrix = List.generate(5, (_) => List.filled(3, 0.0));

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUser = true;
    });
    final users = await FirestoreService().getAllUsers();
    setState(() {
      userList = users;
      // Reset selectedNames dan isManualInput agar tidak error
      for (int i = 0; i < 5; i++) {
        if (i < userList.length) {
          selectedNames[i] = placeholderName;
          isManualInput[i] = false;
          nameControllers[i].clear();
        } else {
          selectedNames[i] = placeholderName;
          isManualInput[i] = true;
          nameControllers[i].clear();
        }
      }
      _isLoadingUser = false;
    });
  }

  // Nilai rating maksimum/minimum untuk normalisasi Cost
  List<int> getMaxValuePerCriteria() {
    List<int> maxValue = [1, 1, 1];
    for (int i = 0; i < 3; i++) {
      int m = 1;
      for (int j = 0; j < 5; j++) {
        int val = int.tryParse(criteriaControllers[j][i].text) ?? 1;
        if (val > m) m = val;
      }
      maxValue[i] = m;
    }
    return maxValue;
  }

  List<int> getMinValuePerCriteria() {
    List<int> minValue = [100, 100, 100];
    for (int i = 0; i < 3; i++) {
      int m = 100;
      for (int j = 0; j < 5; j++) {
        int val = int.tryParse(criteriaControllers[j][i].text) ?? 100;
        if (val < m && val > 0) m = val;
      }
      minValue[i] = m;
    }
    return minValue;
  }

  void calculateSAW() {
    // Matriks keputusan (input user)
    List<List<double>> matrix = List.generate(
        5,
        (i) => List.generate(
            3, (j) => double.tryParse(criteriaControllers[i][j].text) ?? 0.0));
    // Matriks normalisasi
    List<int> minPerKriteria = getMinValuePerCriteria();
    List<List<double>> normalisasi =
        List.generate(5, (_) => List.filled(3, 0.0));
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        double val = matrix[i][j];
        if (val == 0) val = minPerKriteria[j].toDouble();
        normalisasi[i][j] = minPerKriteria[j] / val;
      }
    }
    // Nilai akhir & ranking
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < 5; i++) {
      double nilaiAkhir = 0;
      for (int j = 0; j < 3; j++) {
        nilaiAkhir += bobot[j] * normalisasi[i][j];
      }
      result.add({
        'nama': nameControllers[i].text,
        'nilai': double.parse(nilaiAkhir.toStringAsFixed(3)),
        'normalisasi': normalisasi[i],
        'matrix': matrix[i],
      });
    }
    // Ranking
    result.sort((a, b) => b['nilai'].compareTo(a['nilai']));
    for (int i = 0; i < result.length; i++) {
      result[i]['ranking'] = i + 1;
    }
    // Kembalikan ke urutan input
    result.sort((a, b) => nameControllers
        .indexWhere((c) => c.text == a['nama'])
        .compareTo(nameControllers.indexWhere((c) => c.text == b['nama'])));
    setState(() {
      lastNormalisasi = normalisasi;
      lastResult = result;
      lastMatrix = matrix;
    });
  }

  String? validateInput() {
    for (int i = 0; i < 5; i++) {
      if (selectedNames[i] == null ||
          selectedNames[i] == placeholderName ||
          nameControllers[i].text.trim().isEmpty) {
        return 'Nama pada baris ${i + 1} belum dipilih';
      }
      for (int j = 0; j < 3; j++) {
        if (criteriaControllers[i][j].text.trim().isEmpty) {
          return 'Rating pada baris ${i + 1} kolom ${j == 0 ? 'B3' : j == 1 ? 'Anorganik' : 'Organik'} tidak boleh kosong';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text('Metode SAW',
            style: boldTextStyle.copyWith(color: darkGreenColor)),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGreenColor),
      ),
      body: _isLoadingUser
          ? Center(child: CircularProgressIndicator(color: darkGreenColor))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionCard(
                      title: 'Bobot Preferensi',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.balance,
                                  color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Bobot Preferensi',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                lightGreenColor.withOpacity(0.18)),
                            dataRowMinHeight: 36,
                            dataRowMaxHeight: 44,
                            columnSpacing: 24,
                            border: TableBorder.all(
                                color: lightGreyColor, width: 1),
                            columns: [
                              DataColumn(
                                  label:
                                      Text('Kriteria', style: boldTextStyle)),
                              DataColumn(
                                  label: Text('Bobot', style: boldTextStyle)),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Sampah B3',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child:
                                        Text('0.5', style: regularTextStyle))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Anorganik',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child:
                                        Text('0.3', style: regularTextStyle))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Organik',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child:
                                        Text('0.2', style: regularTextStyle))),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Panduan Rating',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Panduan Rating',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                lightGreenColor.withOpacity(0.18)),
                            dataRowMinHeight: 36,
                            dataRowMaxHeight: 44,
                            columnSpacing: 24,
                            border: TableBorder.all(
                                color: lightGreyColor, width: 1),
                            columns: [
                              DataColumn(
                                  label:
                                      Text('Deskripsi', style: boldTextStyle)),
                              DataColumn(
                                  label: Text('Rating', style: boldTextStyle)),
                              DataColumn(
                                  label:
                                      Text('Keterangan', style: boldTextStyle)),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('< 1 kg',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('4', style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child:
                                        Text('Baik', style: regularTextStyle))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('1-2 kg',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('3', style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Cukup',
                                        style: regularTextStyle))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('3-4 kg',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('2', style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Buruk',
                                        style: regularTextStyle))),
                              ]),
                              DataRow(cells: [
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('> 4 kg',
                                        style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('1', style: regularTextStyle))),
                                DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text('Sangat Buruk',
                                        style: regularTextStyle))),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Input Alternatif & Kriteria',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people,
                                  color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Input Alternatif & Kriteria',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  darkGreenColor.withOpacity(0.18)),
                              dataRowMinHeight: 40,
                              dataRowMaxHeight: 48,
                              columnSpacing: 28,
                              border: TableBorder.symmetric(
                                  inside: BorderSide(
                                      color: lightGreyColor, width: 0.7),
                                  outside: BorderSide(
                                      color: lightGreyColor, width: 1)),
                              columns: [
                                DataColumn(
                                    label: Text('Nama',
                                        style: boldTextStyle.copyWith(
                                            fontSize: 15))),
                                DataColumn(
                                    label: Tooltip(
                                        message: 'Rating Sampah B3',
                                        child: Text('B3',
                                            style: boldTextStyle.copyWith(
                                                fontSize: 15)))),
                                DataColumn(
                                    label: Tooltip(
                                        message: 'Rating Sampah Anorganik',
                                        child: Text('Anorganik',
                                            style: boldTextStyle.copyWith(
                                                fontSize: 15)))),
                                DataColumn(
                                    label: Tooltip(
                                        message: 'Rating Sampah Organik',
                                        child: Text('Organik',
                                            style: boldTextStyle.copyWith(
                                                fontSize: 15)))),
                              ],
                              rows: List.generate(5, (i) {
                                final allUserNames = userList
                                    .where((u) => (u['role'] ?? '') == 'user')
                                    .map((u) => u['name'] as String)
                                    .toList();
                                final selectedOtherNames = List<String>.from(
                                    selectedNames
                                        .map((e) => e ?? placeholderName))
                                  ..removeAt(i);
                                final List<String> dropdownNames = [
                                  placeholderName,
                                  ...allUserNames.where((name) =>
                                      !selectedOtherNames.contains(name) ||
                                      name ==
                                          (selectedNames[i] ?? placeholderName))
                                ];
                                final bool forceManual =
                                    userList.isEmpty || i >= userList.length;
                                String dropdownValue =
                                    (selectedNames[i] ?? placeholderName);
                                if (!dropdownNames.contains(dropdownValue)) {
                                  dropdownValue = placeholderName;
                                }
                                final isZebra = i % 2 == 1;
                                return DataRow(
                                  color:
                                      WidgetStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return darkGreenColor.withOpacity(0.10);
                                    }
                                    return isZebra
                                        ? lightGreenColor.withOpacity(0.08)
                                        : null;
                                  }),
                                  cells: [
                                    DataCell(Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Center(
                                            child: (!forceManual)
                                                ? DropdownButtonFormField<
                                                    String>(
                                                    value: dropdownValue,
                                                    isExpanded: true,
                                                    icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        color: darkGreenColor,
                                                        size: 18),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 0),
                                                    ),
                                                    hint: Text(placeholderName,
                                                        style: regularTextStyle
                                                            .copyWith(
                                                                fontSize: 13)),
                                                    items: dropdownNames
                                                        .map((name) {
                                                      final user =
                                                          userList.firstWhere(
                                                              (u) =>
                                                                  u['name'] ==
                                                                  name,
                                                              orElse: () => {});
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: name,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: Text(
                                                            name,
                                                            style:
                                                                mediumTextStyle
                                                                    .copyWith(
                                                              color: name ==
                                                                      placeholderName
                                                                  ? Colors.grey
                                                                  : name ==
                                                                          dropdownValue
                                                                      ? darkGreenColor
                                                                      : darkGreyColor,
                                                              fontSize: 13,
                                                              fontStyle: name ==
                                                                      placeholderName
                                                                  ? FontStyle
                                                                      .italic
                                                                  : FontStyle
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        final safeVal = val ??
                                                            placeholderName;
                                                        selectedNames[i] =
                                                            safeVal;
                                                        isManualInput[i] =
                                                            safeVal ==
                                                                'Lainnya...';
                                                        if (safeVal !=
                                                                'Lainnya...' &&
                                                            safeVal !=
                                                                placeholderName) {
                                                          nameControllers[i]
                                                              .text = safeVal;
                                                        } else {
                                                          nameControllers[i]
                                                              .text = '';
                                                        }
                                                      });
                                                    },
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2.0),
                                                    child: TextField(
                                                      controller:
                                                          nameControllers[i],
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Masukkan Nama',
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          borderSide: BorderSide(
                                                              color:
                                                                  darkGreenColor,
                                                              width: 1.2),
                                                        ),
                                                        prefixIcon: Icon(
                                                            Icons.edit,
                                                            color:
                                                                darkGreenColor,
                                                            size: 16),
                                                      ),
                                                      style: regularTextStyle
                                                          .copyWith(
                                                              fontSize: 13),
                                                      minLines: 1,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    )),
                                    DataCell(Tooltip(
                                      message: 'Masukkan rating B3',
                                      child: SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: criteriaControllers[i][0],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              hintText: 'Rating',
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          style: regularTextStyle,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    )),
                                    DataCell(Tooltip(
                                      message: 'Masukkan rating Anorganik',
                                      child: SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: criteriaControllers[i][1],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              hintText: 'Rating',
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          style: regularTextStyle,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    )),
                                    DataCell(Tooltip(
                                      message: 'Masukkan rating Organik',
                                      child: SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: criteriaControllers[i][2],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              hintText: 'Rating',
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          style: regularTextStyle,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    )),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Center(
                        child: Text(
                          'Masukkan rating sesuai kriteria: 4 = Baik (<1kg), 3 = Cukup (1-2kg), 2 = Buruk (3-4kg), 1 = Sangat Buruk (>4kg).',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreenColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                        onPressed: () async {
                          final error = validateInput();
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(error,
                                      style: boldTextStyle.copyWith(
                                          color: whiteColor)),
                                  backgroundColor: redColor),
                            );
                          } else {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                title: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: darkGreenColor, size: 28),
                                    SizedBox(width: 10),
                                    Text('Konfirmasi',
                                        style: boldTextStyle.copyWith(
                                            color: darkGreenColor,
                                            fontSize: 20)),
                                  ],
                                ),
                                content: Text(
                                  'Apakah Anda yakin ingin menghitung dan menampilkan hasil SAW dengan data yang sudah diinput?',
                                  style:
                                      regularTextStyle.copyWith(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text('Batal',
                                        style: mediumTextStyle.copyWith(
                                            color: darkGreenColor)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkGreenColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: Text('Ya, Hitung',
                                        style: boldTextStyle.copyWith(
                                            color: whiteColor)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              calculateSAW();
                            }
                          }
                        },
                        child: Text('Hitung SAW',
                            style: boldTextStyle.copyWith(color: whiteColor)),
                      ),
                    ),
                    SizedBox(height: 18),
                    // Tabel Matriks Keputusan (advance style)
                    SectionCard(
                      title: 'Matriks Keputusan',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.table_chart,
                                  color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Matriks Keputusan',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  lightGreenColor.withOpacity(0.18)),
                              dataRowMinHeight: 36,
                              dataRowMaxHeight: 44,
                              columnSpacing: 24,
                              border: TableBorder.all(
                                  color: lightGreyColor, width: 1),
                              columns: [
                                DataColumn(
                                    label: Text('Nama', style: boldTextStyle)),
                                DataColumn(
                                    label: Text('B3', style: boldTextStyle)),
                                DataColumn(
                                    label: Text('Anorganik',
                                        style: boldTextStyle)),
                                DataColumn(
                                    label:
                                        Text('Organik', style: boldTextStyle)),
                              ],
                              rows: List.generate(5, (i) {
                                return DataRow(
                                  cells: [
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(nameControllers[i].text,
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          lastMatrix[i][0].toInt().toString(),
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          lastMatrix[i][1].toInt().toString(),
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          lastMatrix[i][2].toInt().toString(),
                                          style: regularTextStyle),
                                    )),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tabel Matriks Normalisasi (advance style)
                    SectionCard(
                      title: 'Matriks Normalisasi',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_graph,
                                  color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Matriks Normalisasi',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  lightGreenColor.withOpacity(0.18)),
                              dataRowMinHeight: 36,
                              dataRowMaxHeight: 44,
                              columnSpacing: 24,
                              border: TableBorder.all(
                                  color: lightGreyColor, width: 1),
                              columns: [
                                DataColumn(
                                    label: Text('Nama', style: boldTextStyle)),
                                DataColumn(
                                    label: Text('B3', style: boldTextStyle)),
                                DataColumn(
                                    label: Text('Anorganik',
                                        style: boldTextStyle)),
                                DataColumn(
                                    label:
                                        Text('Organik', style: boldTextStyle)),
                              ],
                              rows: List.generate(5, (i) {
                                return DataRow(
                                  cells: [
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(nameControllers[i].text,
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          _formatNorm(lastNormalisasi[i][0]),
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          _formatNorm(lastNormalisasi[i][1]),
                                          style: regularTextStyle),
                                    )),
                                    DataCell(Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Text(
                                          _formatNorm(lastNormalisasi[i][2]),
                                          style: regularTextStyle),
                                    )),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Hasil Perhitungan SAW',
                      color: lightGreenColor.withOpacity(0.07),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 32,
                            headingRowColor: WidgetStateProperty.all(
                                darkGreenColor.withOpacity(0.13)),
                            dataRowMinHeight: 44,
                            dataRowMaxHeight: 54,
                            border: TableBorder.symmetric(
                              inside:
                                  BorderSide(color: lightGreyColor, width: 0.7),
                              outside:
                                  BorderSide(color: lightGreyColor, width: 1),
                            ),
                            columns: [
                              DataColumn(
                                label: Tooltip(
                                  message: 'Nama Alternatif',
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Nama',
                                        style: mediumTextStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        textAlign: TextAlign.left),
                                  ),
                                ),
                              ),
                              DataColumn(
                                numeric: true,
                                label: Tooltip(
                                  message: 'Nilai Akhir SAW',
                                  child: Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text('Nilai Akhir',
                                          style: mediumTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                numeric: true,
                                label: Tooltip(
                                  message: 'Ranking Akhir',
                                  child: Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text('Ranking',
                                          style: mediumTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: ([...lastResult]..sort((a, b) =>
                                    (a['ranking'] as int)
                                        .compareTo(b['ranking'] as int)))
                                .asMap()
                                .entries
                                .map((entry) {
                              final i = entry.key;
                              final row = entry.value;
                              final isTop = row['ranking'] == 1;
                              final isZebra = i % 2 == 1;
                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return darkGreenColor.withOpacity(0.10);
                                  }
                                  return isZebra
                                      ? lightGreenColor.withOpacity(0.08)
                                      : null;
                                }),
                                cells: [
                                  DataCell(Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          row['nama'],
                                          style: isTop
                                              ? boldTextStyle.copyWith(
                                                  fontSize: 16,
                                                  color: darkGreenColor)
                                              : regularTextStyle.copyWith(
                                                  fontSize: 15),
                                          textAlign: TextAlign.left,
                                        ),
                                        if (isTop) ...[
                                          SizedBox(width: 6),
                                          Tooltip(
                                            message: 'Nilai Tertinggi',
                                            child: Icon(Icons.emoji_events,
                                                color: Colors.amber[700],
                                                size: 20),
                                          ),
                                        ]
                                      ],
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      child: Text(
                                        _formatNorm(row['nilai']),
                                        style: isTop
                                            ? boldTextStyle.copyWith(
                                                fontSize: 16,
                                                color: darkGreenColor)
                                            : regularTextStyle.copyWith(
                                                fontSize: 15),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      child: Text(
                                        row['ranking'].toString(),
                                        style: isTop
                                            ? boldTextStyle.copyWith(
                                                fontSize: 16,
                                                color: darkGreenColor)
                                            : regularTextStyle.copyWith(
                                                fontSize: 15),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Masukkan rating sesuai kriteria: 4 = Baik (<1kg), 3 = Cukup (1-2kg), 2 = Buruk (3-4kg), 1 = Sangat Buruk (>4kg).',
                        style: regularTextStyle.copyWith(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: darkGreyColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Proses Detail
                    SizedBox(height: 18),
                    SectionCard(
                      title: 'Proses Detail',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: darkGreenColor, size: 20),
                              SizedBox(width: 8),
                              Text('Langkah-langkah Perhitungan SAW',
                                  style: boldTextStyle.copyWith(
                                      fontSize: 16, color: darkGreenColor)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text('1. Matriks Keputusan',
                              style: boldTextStyle.copyWith(fontSize: 15)),
                          Text(
                              '   Matriks input rating asli yang diisi pada tabel di atas.'),
                          SizedBox(height: 8),
                          Text('2. Matriks Normalisasi',
                              style: boldTextStyle.copyWith(fontSize: 15)),
                          Text(
                              '   Setiap elemen dinormalisasi dengan rumus: r_ij = min(x_j) / x_ij (karena semua kriteria cost).'),
                          SizedBox(height: 8),
                          ...(() {
                            // Sort by ranking ascending
                            final sorted = [...lastResult]..sort((a, b) =>
                                (a['ranking'] as int)
                                    .compareTo(b['ranking'] as int));
                            return List.generate(sorted.length, (idx) {
                              final row = sorted[idx];
                              final i = lastResult
                                  .indexWhere((r) => r['nama'] == row['nama']);
                              String nama = row['nama'];
                              List<int> minPerKriteria =
                                  getMinValuePerCriteria();
                              double r1 = lastNormalisasi[i][0];
                              double r2 = lastNormalisasi[i][1];
                              double r3 = lastNormalisasi[i][2];
                              double v = row['nilai'];
                              double c1 = lastMatrix[i][0];
                              double c2 = lastMatrix[i][1];
                              double c3 = lastMatrix[i][2];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 6),
                                  Text('   Normalisasi untuk $nama:',
                                      style: mediumTextStyle.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '      r₁ = min(B3) / B3 = ${minPerKriteria[0]} / ${c1 != 0 ? c1.toStringAsFixed(3) : '-'} = ${_formatNorm(r1)}'),
                                  Text(
                                      '      r₂ = min(Anorganik) / Anorganik = ${minPerKriteria[1]} / ${c2 != 0 ? c2.toStringAsFixed(3) : '-'} = ${_formatNorm(r2)}'),
                                  Text(
                                      '      r₃ = min(Organik) / Organik = ${minPerKriteria[2]} / ${c3 != 0 ? c3.toStringAsFixed(3) : '-'} = ${_formatNorm(r3)}'),
                                  Text(
                                      '      Nilai Akhir: v = (0.5 × ${_formatNorm(r1)}) + (0.3 × ${_formatNorm(r2)}) + (0.2 × ${_formatNorm(r3)}) = ${_formatNorm(v)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              );
                            });
                          })(),
                          SizedBox(height: 8),
                          Text('3. Ranking',
                              style: boldTextStyle.copyWith(fontSize: 15)),
                          Text(
                              '   Hasil akhir diurutkan dari nilai terbesar ke terkecil. Ranking 1 adalah yang terbaik.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Tambahkan fungsi util format normalisasi
  String _formatNorm(double val) {
    if (val == 1.0) return '1';
    return val.toStringAsFixed(3);
  }
}
