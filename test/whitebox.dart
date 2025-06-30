import 'package:flutter_test/flutter_test.dart';
import 'package:trash_scout/shared/utils/capitalize.dart';

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

  group('Pengujian fungsi capitalize', () {
    test('Mengubah huruf pertama setiap kata menjadi kapital', () {
      expect(capitalize('halo dunia'), 'Halo Dunia');
      expect(capitalize('SELAMAT pagi'), 'Selamat Pagi');
      expect(capitalize('tEsT'), 'Test');
    });
    test('Mengembalikan string kosong jika input kosong', () {
      expect(capitalize(''), '');
    });
  });
}
