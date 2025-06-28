import 'package:flutter_test/flutter_test.dart';

// Contoh fungsi logika yang akan diuji (whitebox)
int tambah(int a, int b) {
  return a + b;
}

void main() {
  group('Whitebox Testing: Fungsi tambah', () {
    test('Penjumlahan dua bilangan positif', () {
      expect(tambah(2, 3), 5);
    });
    test('Penjumlahan bilangan positif dan negatif', () {
      expect(tambah(5, -2), 3);
    });
    test('Penjumlahan nol', () {
      expect(tambah(0, 0), 0);
    });
  });
}
