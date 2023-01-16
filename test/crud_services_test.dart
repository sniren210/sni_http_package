import 'package:dio/dio.dart';
import 'package:sni_http/sni_http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('adds one to input values', () async {
    final crudTest = CrudServicesTest(
      HttpService(
        BaseOptions(
          baseUrl: 'https://api.themoviedb.org',
          queryParameters: {
            'api_key': 'a068ab121d8a0c72662f0d7d9e1c6d84',
          },
        ),
      ),
    );

    final res = await crudTest.find();

    // print(res[0]['original_title']);

    expect(res[0]['original_title'], 'Puss in Boots: The Last Wish');
  });
}

class CrudServicesTest extends CrudService<Map<String, dynamic>> {
  CrudServicesTest(super.httpClient);

  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> map) {
    return map;
  }

  @override
  String get resource => 'https://api.themoviedb.org/3/movie/upcoming';

  @override
  Map<String, dynamic> toJson(Map<String, dynamic> data) {
    return data;
  }
}
