import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class NaverMapScreen extends StatefulWidget {
  @override
  _NaverMapScreenState createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  StompClient? _stompClient;
  late NaverMapController _mapController;
  Set<NMarker> _busMarkers = {};

  @override
  void initState() {
    super.initState();
    _connectStomp();
  }

  void _connectStomp() {
    // STOMP 클라이언트 생성 및 활성화
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:1111/ws', // 백엔드 STOMP 엔드포인트
        onConnect: _onConnect,
        onWebSocketError: (error) => print("[ERROR] WebSocket 에러: $error"),
        onStompError: (StompFrame frame) =>
            print("[ERROR] STOMP 에러: ${frame.body}"),
        onDisconnect: (frame) => print("[DEBUG] STOMP 연결 종료됨"),
      ),
    );

    _stompClient!.activate();
    print("[DEBUG] STOMP 연결 시도 중...");
  }

  void _onConnect(StompFrame frame) {
    print("[DEBUG] STOMP 연결 성공");
    // "/topic/masan" 구독 시작
    _stompClient!.subscribe(
      destination: '/topic/masan',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          print("[DEBUG] 수신된 데이터: ${frame.body}");
          try {
            // JSON 파싱 (백엔드의 BusLocationDTO에 맞춰 vehicleId, latitude, longitude를 포함)
            final decodedData = jsonDecode(frame.body!);
            _updateBusMarkers(decodedData);
          } catch (e) {
            print("[ERROR] 데이터 파싱 에러: $e");
          }
        }
      },
    );
  }

  void _updateBusMarkers(dynamic data) {
    // 데이터가 List 형태라고 가정 (또는 최상위 객체 내 busLocations 배열일 경우에 맞게 수정)
    List<dynamic> busLocations;
    if (data is List) {
      busLocations = data;
    } else if (data is Map && data['busLocations'] is List) {
      busLocations = data['busLocations'];
    } else {
      print("[ERROR] 예상하지 못한 데이터 형식: $data");
      return;
    }

    Set<NMarker> newMarkers = {};
    for (var bus in busLocations) {
      // 각 버스 데이터에서 위도, 경도, 차량 ID 추출
      double lat = double.tryParse(bus['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(bus['longitude'].toString()) ?? 0.0;
      String vehicleId = bus['vehicleId']?.toString() ?? 'unknown';

      final marker = NMarker(
        id: vehicleId,
        position: NLatLng(lat, lng),
      );

      // 터치 이벤트 처리 (원하는 경우 추가 기능 구현)
      marker.setOnTapListener((overlay) {
        print("[DEBUG] 터치된 버스 - ID: $vehicleId, 위치: ($lat, $lng)");
      });

      newMarkers.add(marker);
    }

    setState(() {
      _busMarkers = newMarkers;
    });

    if (_mapController != null) {
      // 지도에서 기존 오버레이 제거 후 새 마커 추가
      _mapController.clearOverlays();
      _mapController.addOverlayAll(_busMarkers);
      print("[DEBUG] 지도에 ${_busMarkers.length}개의 마커 추가됨.");
    }
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // 연한 초록색 배경
      appBar: AppBar(
        title: Text(
          "네이버 지도 - 실시간 마산 버스 위치",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff388e3c), // AppBar 초록색
        foregroundColor: Colors.white,
      ),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5665, 126.9780), // 서울 좌표 (필요에 따라 변경)
            zoom: 14,
          ),
          locationButtonEnable: true,
          // 필요한 추가 옵션들을 넣을 수 있습니다.
        ),
        onMapReady: (controller) {
          _mapController = controller;
          // 초기 오버레이 추가 (없으면 빈 상태)
          _mapController.addOverlayAll(_busMarkers);
          print("[DEBUG] 지도 준비 완료, 초기 마커 수: ${_busMarkers.length}");
        },
      ),
    );
  }
}