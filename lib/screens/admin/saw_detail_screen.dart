import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/services/firestore_service.dart';

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

  // Kriteria rating controller: [user][kriteria]
  final List<List<TextEditingController>> criteriaControllers = List.generate(
    5,
    (_) => List.generate(3, (_) => TextEditingController()),
  );

  // Bobot Preferensi (bisa diedit manual kalau ingin dinamis)
  final List<double> bobot = [0.5, 0.3, 0.2]; // C1, C2, C3

  List<Map<String, dynamic>> userList = [];
  bool _isLoadingUser = true;

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
      userList = users.take(5).toList();
      for (int i = 0; i < userList.length; i++) {
        nameControllers[i].text = userList[i]['name'] ?? '';
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

  // Hitung SAW (Simple Additive Weighting)
  List<Map<String, dynamic>> hitungSAW() {
    List<List<double>> normalisasi =
        List.generate(5, (_) => List.filled(3, 0.0));
    var minPerKriteria = getMinValuePerCriteria();

    // Normalisasi cost: min / value
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        double val = double.tryParse(criteriaControllers[i][j].text) ?? 0.0;
        if (val == 0) val = minPerKriteria[j].toDouble(); // kosong pakai min
        normalisasi[i][j] = minPerKriteria[j] / val;
      }
    }

    // Hitung nilai akhir & ranking
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < 5; i++) {
      double nilaiAkhir = 0;
      for (int j = 0; j < 3; j++) {
        nilaiAkhir += bobot[j] * normalisasi[i][j];
      }
      result.add({
        'nama': nameControllers[i].text,
        'nilai': double.parse(nilaiAkhir.toStringAsFixed(3)),
      });
    }

    // Ranking
    result.sort((a, b) => b['nilai'].compareTo(a['nilai']));
    for (int i = 0; i < result.length; i++) {
      result[i]['ranking'] = i + 1;
    }
    // Kembalikan ke urutan input (jika ingin tampil sesuai input)
    result.sort((a, b) => nameControllers
        .indexWhere((c) => c.text == a['nama'])
        .compareTo(nameControllers.indexWhere((c) => c.text == b['nama'])));
    return result;
  }

  String? validateInput() {
    for (int i = 0; i < 5; i++) {
      if (nameControllers[i].text.trim().isEmpty) {
        return 'Nama pada baris ${i + 1} tidak boleh kosong';
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
    final sawResult = hitungSAW();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text('Detail SAW',
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
                      title: 'Tabel Bobot Preferensi',
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text('Kriteria', style: mediumTextStyle)),
                          DataColumn(
                              label: Text('Bobot', style: mediumTextStyle)),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('Sampah B3')),
                            DataCell(Text('0.5'))
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Anorganik')),
                            DataCell(Text('0.3'))
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Organik')),
                            DataCell(Text('0.2'))
                          ]),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Panduan Rating',
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text('Deskripsi', style: mediumTextStyle)),
                          DataColumn(
                              label: Text('Rating', style: mediumTextStyle)),
                          DataColumn(
                              label:
                                  Text('Keterangan', style: mediumTextStyle)),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('< 1 kg')),
                            DataCell(Text('4')),
                            DataCell(Text('Baik'))
                          ]),
                          DataRow(cells: [
                            DataCell(Text('1-2 kg')),
                            DataCell(Text('3')),
                            DataCell(Text('Cukup'))
                          ]),
                          DataRow(cells: [
                            DataCell(Text('3-4 kg')),
                            DataCell(Text('2')),
                            DataCell(Text('Buruk'))
                          ]),
                          DataRow(cells: [
                            DataCell(Text('> 4 kg')),
                            DataCell(Text('1')),
                            DataCell(Text('Sangat Buruk'))
                          ]),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: 'Input Alternatif & Kriteria',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          columns: [
                            DataColumn(
                                label: Column(
                              children: [
                                Text('No', style: mediumTextStyle),
                                SizedBox(height: 4)
                              ],
                            )),
                            DataColumn(
                                label: Column(
                              children: [
                                Text('Nama', style: mediumTextStyle),
                                SizedBox(height: 4),
                                Text('User',
                                    style: regularTextStyle.copyWith(
                                        fontSize: 11, color: darkGreyColor))
                              ],
                            )),
                            DataColumn(
                                label: Column(
                              children: [
                                Text('B3', style: mediumTextStyle),
                                SizedBox(height: 4),
                                Text('Sampah B3',
                                    style: regularTextStyle.copyWith(
                                        fontSize: 11, color: darkGreyColor))
                              ],
                            )),
                            DataColumn(
                                label: Column(
                              children: [
                                Text('Anorganik', style: mediumTextStyle),
                                SizedBox(height: 4),
                                Text('Sampah Anorganik',
                                    style: regularTextStyle.copyWith(
                                        fontSize: 11, color: darkGreyColor))
                              ],
                            )),
                            DataColumn(
                                label: Column(
                              children: [
                                Text('Organik', style: mediumTextStyle),
                                SizedBox(height: 4),
                                Text('Sampah Organik',
                                    style: regularTextStyle.copyWith(
                                        fontSize: 11, color: darkGreyColor))
                              ],
                            )),
                          ],
                          rows: List.generate(5, (i) {
                            return DataRow(cells: [
                              DataCell(
                                  Text('${i + 1}', style: regularTextStyle)),
                              DataCell(SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: nameControllers[i],
                                  decoration: InputDecoration(
                                      hintText: 'Nama',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  style: regularTextStyle,
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: criteriaControllers[i][0],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: 'Rating',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  style: regularTextStyle,
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: criteriaControllers[i][1],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: 'Rating',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  style: regularTextStyle,
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: criteriaControllers[i][2],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: 'Rating',
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  style: regularTextStyle,
                                ),
                              )),
                            ]);
                          }),
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
                        onPressed: () {
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
                            setState(() {});
                          }
                        },
                        child: Text('Hitung SAW',
                            style: boldTextStyle.copyWith(color: whiteColor)),
                      ),
                    ),
                    SectionCard(
                      title: 'Hasil Perhitungan SAW',
                      color: lightGreenColor.withOpacity(0.07),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 32,
                          columns: [
                            DataColumn(
                                label: Text('Nama', style: mediumTextStyle)),
                            DataColumn(
                                label: Text('Nilai Akhir',
                                    style: mediumTextStyle)),
                            DataColumn(
                                label: Text('Ranking', style: mediumTextStyle)),
                          ],
                          rows: sawResult.map((data) {
                            final isTop = data['ranking'] == 1;
                            return DataRow(
                              color: isTop
                                  ? MaterialStateProperty.all(
                                      lightGreenColor.withOpacity(0.25))
                                  : null,
                              cells: [
                                DataCell(Text(data['nama'],
                                    style: regularTextStyle)),
                                DataCell(Text(data['nilai'].toString(),
                                    style: regularTextStyle)),
                                DataCell(Row(
                                  children: [
                                    Text(data['ranking'].toString(),
                                        style: boldTextStyle.copyWith(
                                            color: isTop
                                                ? darkGreenColor
                                                : blackColor)),
                                    if (isTop) ...[
                                      SizedBox(width: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: darkGreenColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.emoji_events,
                                                color: whiteColor, size: 16),
                                            SizedBox(width: 3),
                                            Text('Terbaik',
                                                style: boldTextStyle.copyWith(
                                                    color: whiteColor,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
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
                  ],
                ),
              ),
            ),
    );
  }
}
