import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
