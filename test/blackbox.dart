import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trash_scout/main.dart';

void main() {
  testWidgets('Blackbox Testing: Tombol menambah angka',
      (WidgetTester tester) async {
    // Widget sederhana untuk diuji
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CounterWidget(),
      ),
    ));

    // Pastikan angka awal 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tekan tombol tambah
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Pastikan angka bertambah
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('SplashScreen menampilkan logo aplikasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Cek apakah gambar logo tampil
    final logoFinder = find.byType(Image);
    expect(logoFinder, findsOneWidget);
    // Cek apakah ada widget dengan asset app_logo.png
    final assetFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        if (decoration.image != null && decoration.image!.image is AssetImage) {
          final asset = (decoration.image!.image as AssetImage).assetName;
          return asset == 'assets/app_logo.png';
        }
      }
      return false;
    });
    expect(assetFinder, findsOneWidget);
  });
}

class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$_counter', style: TextStyle(fontSize: 32)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _counter++;
            });
          },
        ),
      ],
    );
  }
}
