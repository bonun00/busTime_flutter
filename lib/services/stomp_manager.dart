import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
class StompManager {
  StompClient? _client;

  void connect({
    required String region,
    required Function(List<dynamic>) onBusDataReceived,
    required Function(String) onError,
    required VoidCallback onConnected,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:1111/ws',
        onConnect: (frame) {
          _client!.subscribe(
            destination: '/topic/$region',
            callback: (frame) {
              try {
                final body = frame.body;
                if (body == null) return;
                final data = jsonDecode(body);
                final buses = data is List ? data : data['busLocations'] ?? [];
                onBusDataReceived(buses);
              } catch (e) {
                onError('데이터 파싱 오류');
              }
            },
          );
          _client!.send(destination: '/app/$region', body: '');
          onConnected();
        },
        onWebSocketError: (error) => onError(error.toString()),
        onStompError: (frame) => onError(frame.body ?? 'STOMP 오류'),
      ),
    );

    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
  }
}