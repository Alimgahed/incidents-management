import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/offline/network/cache_key.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';

void main() {
  test('canonicalizes query order and omits the browser cache buster', () {
    final first = Uri.parse('https://api.example.test/incidents?z=2&a=1&_t=10');
    final second = Uri.parse(
      'https://api.example.test/incidents?_t=99&a=1&z=2',
    );

    expect(CacheKey.fromUri(first), CacheKey.fromUri(second));
    expect(CacheKey.fromUri(first), isNot(contains('_t')));
  });

  test('sorts repeated query values without changing the path', () {
    final first = Uri.parse('https://api.example.test/incidents?tag=b&tag=a');
    final second = Uri.parse('https://api.example.test/incidents?tag=a&tag=b');

    expect(CacheKey.fromUri(first), CacheKey.fromUri(second));
    expect(CacheKey.fromUri(first), contains('/incidents?'));
  });

  test(
    'cache hits equivalent URLs, expires, refreshes and invalidates',
    () async {
      final adapter = _CountingAdapter();
      final cache = CacheInterceptor(
        cacheDuration: const Duration(milliseconds: 20),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(cache);
      addTearDown(dio.close);

      final first = await dio.get<Map<String, dynamic>>(
        '/incidents',
        queryParameters: {'page': 1, 'status': 'open'},
      );
      final equivalent = await dio.get<Map<String, dynamic>>(
        '/incidents',
        queryParameters: {'status': 'open', 'page': 1},
      );
      expect(first.data, equivalent.data);
      expect(adapter.requestCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 30));
      await dio.get(
        '/incidents',
        queryParameters: {'page': 1, 'status': 'open'},
      );
      expect(adapter.requestCount, 2);

      await dio.get(
        '/incidents',
        queryParameters: {'page': 1, 'status': 'open'},
        options: Options(extra: {'noCache': true}),
      );
      expect(adapter.requestCount, 3);

      await dio.post('/incidents', data: {'title': 'new'});
      await dio.get(
        '/incidents',
        queryParameters: {'page': 1, 'status': 'open'},
      );
      expect(adapter.requestCount, 5);
    },
  );
}

class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final body = options.method == 'POST'
        ? '{"created":true}'
        : '{"count":$requestCount}';
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
