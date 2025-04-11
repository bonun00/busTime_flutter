import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/BusApiService.dart';


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
  String _selectedRegion = 'masan'; // ✅ 추가: 기본 지역
  final BusApiService _busApiService = BusApiService();  //
  Set<NMarker> _stopMarkers = {};
// 검색 관련 변수
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  List<dynamic> _allStops = []; // 모든 정류장 데이터를 저장

  // 버스 목록 패널 크기 조절 관련 변수
  double _busPanelHeight = 250.0; // 초기 높이
  double _minPanelHeight = 60.0;  // 최소 높이
  double _maxPanelHeight = 500.0; // 최대 높이
  bool _isDragging = false;       // 드래그 중인지 여부


// 정류장 검색 메서드
  void _searchStops(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allStops.where((stop) {
        final nodeNm = stop['nodeNm']?.toString().toLowerCase() ?? '';
        return nodeNm.contains(query.toLowerCase());
      }).toList();
    });
  }

// 검색 결과에서 정류장 선택 메서드
  void _selectSearchedStop(dynamic stop) {
    double lat = stop['latitude'];
    double lng = stop['longitude'];
    String nodeNm = stop['nodeNm'] ?? '';
    String nodeId = stop['nodeId'] ?? '';

    // 검색 UI 닫기
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });

    // 선택한 정류장으로 카메라 이동
    _moveCameraTo(lat, lng);

    // 선택한 정류장 강조 표시
    _updateBorderOverlay(lat, lng);

    // 해당 정류장의 도착 정보 보여주기
    _busApiService.fetchStopTime(nodeId).then((arrivalInfo) {
      _showArrivalBottomSheet(context, nodeNm, arrivalInfo);
    });
  }
  @override
  void initState() {
    super.initState();
    _connectStomp();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // _fetchAndDisplayPath(_selectedRegion == 'masan' ? '마산' : '칠원');
    _requestLocationPermission();
  }

  // 위치 권한 요청 메서드
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
  }

  void _renderAllMarkers() async {
    if (_mapController == null) return;

    if (_stopMarkers.isEmpty && _busMarkers.isEmpty) {
      print("⛔ 마커가 없어서 렌더링하지 않음");
      return;
    }

    print("🟢 정류장 마커 수: ${_stopMarkers.length}");
    print("🟡 버스 마커 수: ${_busMarkers.length}");

    // await _mapController.clearOverlays();

    // 리스트를 Set으로 변환해서 전달
    await _mapController.addOverlayAll({..._stopMarkers, ..._busMarkers});

    if (_selectedCircleOverlay != null) {
      await _mapController.addOverlay(_selectedCircleOverlay!);
    }
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

  void _subscribeToRegion(String region) {
    if (_stompClient != null && _stompClient!.connected) {
      _stompClient!.subscribe(
        destination: '/topic/$region',
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

      // ✅ 지역 요청 즉시 데이터 받기
      _stompClient!.send(destination: '/app/$region', body: '');
    }
  }
  // 패널 높이 조절 메서드
  void _updatePanelHeight(double delta) {
    setState(() {
      _busPanelHeight = (_busPanelHeight - delta).clamp(_minPanelHeight, _maxPanelHeight);

      // 높이에 따라 목록 확장/축소 상태 업데이트
      if (_busPanelHeight <= _minPanelHeight + 30) {
        _isListExpanded = false;
        _animationController.reverse();
      } else {
        _isListExpanded = true;
        _animationController.forward();
      }
    });
  }

  void _onConnect(StompFrame frame) {
    print("[DEBUG] STOMP 연결 성공: ${frame.headers}");
    _subscribeToRegion(_selectedRegion);
  }

  void _changeRegion(String region) {
    setState(() {
      _selectedRegion = region;
      _busMarkers.clear();
      _stopMarkers.clear();
      _busList.clear();
      _isLoading = true;
    });

    _subscribeToRegion(region);
    _fetchAndDisplayPath(region == 'masan' ? '마산' : '칠원');

    setState(() {
      _isLoading = false;
    });
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
    _renderAllMarkers();

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
    _searchController.dispose();
    super.dispose();
  }

  // 검색 결과 위젯
  Widget _buildSearchResults() {
    return _isSearching
        ? Container(
      color: Colors.white,
      child: _searchResults.isEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("검색 결과가 없습니다."),
        ),
      )
          : ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final stop = _searchResults[index];
          return ListTile(
            leading: Icon(Icons.location_on, color: Color(0xFF388E3C)),
            title: Text(stop['nodeNm'] ?? ''),
            subtitle: Text("정류장 ID: ${stop['nodeId'] ?? ''}"),
            onTap: () => _selectSearchedStop(stop),
          );
        },
      ),
    )
        : SizedBox.shrink();
  }
  Future<void> _fetchAndDisplayPath(String direction) async {
    try {
      List<dynamic> response = await _busApiService.fetchPath(direction);

      if (response.isEmpty || _mapController == null) return;
      // 모든 정류장 데이터 저장 (검색에 사용) - 이 줄 추가
      setState(() {
        _allStops = response;
      });
      Set<NMarker> newStopMarkers = {};

      for (var stop in response) {
        double lat = stop['latitude'];
        double lng = stop['longitude'];
        String nodeNm = stop['nodeNm'] ?? '';
        String nodeId = stop['nodeId'] ?? '';

        final marker = NMarker(
          id: nodeId,
          position: NLatLng(lat, lng),
          caption: NOverlayCaption(
            text: nodeNm,
            textSize: 12,
            color: Colors.black,
            haloColor: Colors.white,
          ),
          icon:await NOverlayImage.fromAssetImage('assets/images/big-location-marker.png',
          ),
        );
        marker.setOnTapListener((overlay) async {
          final arrivalInfo = await _busApiService.fetchStopTime(nodeId); // ✅ nodeId로 API 호출
          _showArrivalBottomSheet(context, nodeNm, arrivalInfo); // ✅ 바텀시트에 보여주기
        });
        newStopMarkers.add(marker);
      }

      setState(() {
        _stopMarkers = newStopMarkers;
      });

      _renderAllMarkers();
    } catch (e) {
      print("정류장 마커 표시 실패: $e");
    }
  }
  void _showArrivalBottomSheet(BuildContext context, String stopName, List<dynamic> arrivalInfo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$stopName 정류장 도착 정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              arrivalInfo.isEmpty
                  ? Text("도착 예정 버스가 없습니다.")
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: arrivalInfo.length,
                itemBuilder: (context, index) {
                  final info = arrivalInfo[index];
                  return ListTile(
                    leading: Icon(Icons.directions_bus, color: Colors.green),
                    title: Text("${info['routeNo']}번 (${info['routeTp']})"),
                    subtitle: Text("도착까지 ${info['arrTime']}분 | 남은 정류장 ${info['arrPrevStationCnt']}개"),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
              '실시간 버스'
              ,style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _changeRegion('masan'),
            child: Text('마산', style: TextStyle(color: _selectedRegion == 'masan' ? Colors.green[800] : Colors.grey)),
          ),
          TextButton(
            onPressed: () => _changeRegion('chilwon'),
            child: Text('칠원', style: TextStyle(color: _selectedRegion == 'chilwon' ? Colors.green[800] : Colors.grey)),
          ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: _searchStops,
                decoration: InputDecoration(
                  hintText: '정류장 이름으로 검색',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF388E3C)),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchResults = [];
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 검색 결과 (새로 추가)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: _isSearching ? 0 : null,
            child: _buildSearchResults(),
          ),
          // 네이버 지도
          Positioned(
              top: 60,  // 검색창 높이만큼 아래로
              left: 0,
              right: 0,
              bottom: 0,
              child: _isSearching
                  ? Container() // 검색 중에는 지도 숨김
                  : NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.3088233, 128.5185542),
                zoom: 14,
              ),
              locationButtonEnable: true, // 네이버 맵의 기본 위치 버튼 활성화
              contentPadding: EdgeInsets.only(bottom: _isListExpanded ? _busPanelHeight : _minPanelHeight),
              scaleBarEnable: false,
            ),
            onMapReady: (controller) async{
              _mapController = controller;
              await _fetchAndDisplayPath(_selectedRegion == 'masan' ? '마산' : '칠원');

              _renderAllMarkers();
              _mapController.addOverlayAll(_busMarkers);
              if (_selectedCircleOverlay != null) {
                _mapController.addOverlay(_selectedCircleOverlay!);
              }
              final locationOverlay = _mapController.getLocationOverlay();

              // 원 표시 제거
              locationOverlay.setCircleRadius(0.0);
            },
          ),
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

          // 버스 목록 패널
          // 버스 목록 패널 (수정: 드래그 가능하게)
          if (!_isSearching)
            AnimatedPositioned(
              duration: Duration(milliseconds: _isDragging ? 0 : 300), // 드래그 중에는 애니메이션 없음
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _isListExpanded ? 0 : -(_busPanelHeight - _minPanelHeight),
              height: _busPanelHeight,
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
                    // 드래그 핸들
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _isDragging = true;
                          _updatePanelHeight(details.delta.dy);
                        });
                      },
                      onVerticalDragEnd: (details) {
                        setState(() {
                          _isDragging = false;
                          // 속도에 따라 패널 완전히 올리기/내리기
                          if (details.velocity.pixelsPerSecond.dy > 200) {
                            // 아래로 빠르게 스와이프 - 패널 줄이기
                            _busPanelHeight = _minPanelHeight;
                            _isListExpanded = false;
                            _animationController.reverse();
                          } else if (details.velocity.pixelsPerSecond.dy < -200) {
                            // 위로 빠르게 스와이프 - 패널 키우기
                            _busPanelHeight = _maxPanelHeight;
                            _isListExpanded = true;
                            _animationController.forward();
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            // 드래그 핸들 인디케이터
                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(height: 8),
                            // 기존 헤더 내용
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
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
                          ],
                        ),
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