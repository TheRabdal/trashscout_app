import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://emsifa.github.io/api-wilayah-indonesia/api/';

  Future<List<dynamic>> getProvinces() async {
    final String provincesUrl = '$baseUrl' + 'provinces.json';
    final response = await http.get(Uri.parse(provincesUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat provinsi');
    }
  }

  Future<List<dynamic>> getRegencies(String provinceId) async {
    final String regenciesUrl = '$baseUrl' + 'regencies/$provinceId.json';
    final response = await http.get(Uri.parse(regenciesUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat kabupaten');
    }
  }
}
