import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:permission_handler/permission_handler.dart';

class NaverMapScreen extends StatefulWidget {
  @override
  _NaverMapScreenState createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> with SingleTickerProviderStateMixin {
  StompClient? _stompClient;
  late NaverMapController _mapController;
  Set<NMarker> _busMarkers = {};
  List<dynamic> _busList = [];
  String? _selectedMarkerId;
  NCircleOverlay? _selectedCircleOverlay;
  NMultipartPathOverlay? _pathOverlay;
  bool _isLoading = true;
  late AnimationController _animationController;
  bool _isListExpanded = true;

  @override
  void initState() {
    super.initState();
    _connectStomp();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _requestLocationPermission();
  }

  // 위치 권한 요청 메서드
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
  }

  void _connectStomp() {
    setState(() {
      _isLoading = true;
    });

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:1111/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) {
          print("[ERROR] WebSocket 에러: $error");
          _showErrorSnackBar("서버 연결에 실패했습니다. 다시 시도해주세요.");
          setState(() {
            _isLoading = false;
          });
        },
        onStompError: (StompFrame frame) {
          print("[ERROR] STOMP 에러: ${frame.body}");
          _showErrorSnackBar("데이터 수신 중 오류가 발생했습니다.");
          setState(() {
            _isLoading = false;
          });
        },
        onDisconnect: (frame) {
          print("[DEBUG] STOMP 연결 종료됨: ${frame.headers}");
          setState(() {
            _isLoading = false;
          });
        },
      ),
    );
    _stompClient!.activate();
    print("[DEBUG] STOMP 연결 시도 중...");
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _onConnect(StompFrame frame) {
    print("[DEBUG] STOMP 연결 성공: ${frame.headers}");

    _stompClient!.subscribe(
      destination: '/topic/chilwon',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final decodedData = jsonDecode(frame.body!);
            _updateBusData(decodedData);
            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            print("[ERROR] 데이터 파싱 에러: $e");
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          print("[DEBUG] 수신된 데이터가 없습니다.");
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _updateBusData(dynamic data) {
    List<dynamic> busLocations;
    if (data is List) {
      busLocations = data;
    } else if (data is Map && data['busLocations'] is List) {
      busLocations = data['busLocations'];
    } else {
      print("[ERROR] 예상하지 못한 데이터 형식: $data");
      return;
    }

    setState(() {
      _busList = busLocations;
    });

    Set<NMarker> newMarkers = {};
    for (var bus in busLocations) {
      double lat = double.tryParse(bus['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(bus['longitude'].toString()) ?? 0.0;
      String vehicleId = bus['vehicleId']?.toString() ?? 'unknown';
      String busNumber = bus['busNumber']?.toString() ?? '';

      // 마커를 생성하고 버스 번호를 포함한 캡션 추가
      final marker = NMarker(
        id: vehicleId,
        position: NLatLng(lat, lng),
        caption: NOverlayCaption(
          text: busNumber,
          textSize: 14,
          color: Colors.white,
          haloColor: Colors.black,
        ),
        icon: NOverlayImage.fromAssetImage('assets/images/bus_marker.png'),
      );

      marker.setOnTapListener((overlay) {
        setState(() {
          _selectedMarkerId = vehicleId;
        });
        _moveCameraTo(lat, lng);
        _updateBorderOverlay(lat, lng);
        _showBusInfo(bus);
      });

      newMarkers.add(marker);
    }

    setState(() {
      _busMarkers = newMarkers;
    });

    if (_mapController != null) {
      _mapController.clearOverlays();
      _mapController.addOverlayAll(_busMarkers);
      if (_selectedCircleOverlay != null) {
        _mapController.addOverlay(_selectedCircleOverlay!);
      }
    }
  }

  void _showBusInfo(dynamic bus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF388E3C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${bus['busNumber'] ?? '알 수 없음'}번 버스",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "차량 ID: ${bus['vehicleId'] ?? '알 수 없음'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoRow(Icons.location_on, "현재 위치", "${bus['nodenm'] ?? '정보 없음'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF388E3C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("닫기"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF388E3C), size: 18),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _moveCameraTo(double lat, double lng) {
    _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(lat, lng),
          zoom: 16,
        ),
      ),
    );
  }

  void _updateBorderOverlay(double lat, double lng) {
    // 원형 오버레이 타입만 제거
    _mapController.clearOverlays(type: NOverlayType.circleOverlay);

    _selectedCircleOverlay = NCircleOverlay(
      id: "selected_circle",
      center: NLatLng(lat, lng),
      radius: 30,
      color: Colors.red.withOpacity(0.3),
      outlineColor: Colors.red,
      outlineWidth: 2,
    );

    _mapController.addOverlay(_selectedCircleOverlay!);
  }

  void _toggleListExpanded() {
    setState(() {
      _isListExpanded = !_isListExpanded;
      if (_isListExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF388E3C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '실시간 버스 위치',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _connectStomp();
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // 네이버 지도
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.3088233, 128.5185542),
                zoom: 14,
              ),
              locationButtonEnable: true, // 네이버 맵의 기본 위치 버튼 활성화
              contentPadding: EdgeInsets.only(bottom: _isListExpanded ? 250 : 60),
              scaleBarEnable: false,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _mapController.addOverlayAll(_busMarkers);
              if (_selectedCircleOverlay != null) {
                _mapController.addOverlay(_selectedCircleOverlay!);
              }
              final locationOverlay = _mapController.getLocationOverlay();

              // 원 표시 제거
              locationOverlay.setCircleRadius(0.0);

              // 커스텀 마커 이미지를 사용해야 함
              // 1. assets/images/ 폴더에 큰 크기의 내 위치 아이콘을 추가해야 함 (예: big_location_marker.png)
              // 2. pubspec.yaml 파일에 해당 에셋 경로 추가 필요

              // 큰 크기의 커스텀 이미지로 설정 (assets에 이미지 추가 필요)
              locationOverlay.setIcon(NOverlayImage.fromAssetImage('assets/images/big-location-marker.svg'));
            },
          ),

          // 로딩 표시기
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF388E3C)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "버스 정보를 불러오는 중...",
                          style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 버스 목록 토글 버튼
          Positioned(
            right: 16,
            bottom: _isListExpanded ? 250 : 16,
            child: FloatingActionButton(
              onPressed: _toggleListExpanded,
              backgroundColor: Color(0xFF388E3C),
              child: Icon(
                _isListExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
              mini: true,
            ),
          ),

          // 버스 목록 패널
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isListExpanded ? 0 : -190,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 버스 목록 헤더
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "실시간 버스 목록",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${_busList.length}대 운행 중",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 버스 목록
                  Expanded(
                    child: _busList.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "실시간 버스 정보가 없습니다.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: _busList.length,
                      itemBuilder: (context, index) {
                        var bus = _busList[index];
                        String vehicleId = bus['vehicleId']?.toString() ?? 'unknown';
                        String busNumber = bus['busNumber']?.toString() ?? '';
                        double lat = double.tryParse(bus['latitude'].toString()) ?? 0.0;
                        double lng = double.tryParse(bus['longitude'].toString()) ?? 0.0;

                        bool isSelected = vehicleId == _selectedMarkerId;

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          elevation: isSelected ? 4 : 1,
                          shadowColor: isSelected ? Color(0xFF388E3C).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? Color(0xFF388E3C) : Colors.transparent,
                              width: isSelected ? 2 : 0,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMarkerId = vehicleId;
                              });
                              _moveCameraTo(lat, lng);
                              _updateBorderOverlay(lat, lng);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFF388E3C) : Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        busNumber,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Color(0xFF388E3C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${bus['routenm'] ?? '정보 없음'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "차량 번호 $vehicleId",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFF388E3C),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}