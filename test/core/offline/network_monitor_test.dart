import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';

class _FakeConnectivity implements Connectivity {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> current = [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  void emit(List<ConnectivityResult> results) {
    current = results;
    _controller.add(results);
  }

  void dispose() => _controller.close();
}

class _CountingProbeAdapter implements HttpClientAdapter {
  int callCount = 0;
  final Duration delay;
  final int statusCode;

  _CountingProbeAdapter({this.delay = const Duration(milliseconds: 50), this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return ResponseBody.fromString('OK', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _FakeConnectivity fakeConnectivity;

  setUp(() {
    fakeConnectivity = _FakeConnectivity();
  });

  tearDown(() {
    fakeConnectivity.dispose();
  });

  test('concurrent refresh calls coalesce into a single HTTP probe', () async {
    final adapter = _CountingProbeAdapter(delay: const Duration(milliseconds: 60));
    final dio = Dio()..httpClientAdapter = adapter;

    final monitor = NetworkMonitorService(
      connectivity: fakeConnectivity,
      probeClient: dio,
      baseUrl: 'https://test.server.local',
      probeIntervalOnline: const Duration(hours: 1),
      probeIntervalOffline: const Duration(hours: 1),
    );

    await monitor.initialize();

    // Trigger multiple concurrent refreshes while one is already in flight
    final futures = [
      monitor.refresh(),
      monitor.refresh(),
      monitor.refresh(),
    ];

    final results = await Future.wait(futures);
    expect(results, [true, true, true]);
    expect(monitor.isOnline, isTrue);

    // Initial probe from initialize + coalesced probes (should only be 2 total calls at most, not 4)
    expect(adapter.callCount, lessThanOrEqualTo(2));

    await monitor.dispose();
  });

  test('offline connectivity result transitions state immediately', () async {
    final monitor = NetworkMonitorService(
      connectivity: fakeConnectivity,
      baseUrl: 'https://test.server.local',
    );

    await monitor.initialize();
    fakeConnectivity.emit([ConnectivityResult.none]);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(monitor.isOffline, isTrue);

    await monitor.dispose();
  });
}
