import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/map_widgets/map_marker.dart';
import '../widgets/map_widgets/stop_list_bottom_sheet.dart';
import '../services/BusApiService.dart';

class NaverMapScreen extends StatefulWidget {
  @override
  _NaverMapScreenState createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> with SingleTickerProviderStateMixin {
  late NaverMapController _mapController;
  Set<NMarker> _stopMarkers = {};
  List<dynamic> _allStops = [];
  String? _selectedMarkerId;
  NCircleOverlay? _selectedCircleOverlay;
  bool _isLoading = true;
  late AnimationController _animationController;
  final BusApiService _busApiService = BusApiService();
  final GlobalKey<StopListBottomSheetState> _stopListBottomSheetKey = GlobalKey<StopListBottomSheetState>();

  // 바텀시트 높이 관련 변수
  double _bottomSheetHeight = 300.0;

  // 스캐폴드 키 (바텀시트용)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
    setState(() => _isLoading = false);
  }

  void _renderAllMarkers() async {
    if (_mapController == null) return;
    if (_stopMarkers.isEmpty) return;
    await _mapController.clearOverlays();
    await _mapController.addOverlayAll(_stopMarkers);
    if (_selectedCircleOverlay != null) {
      await _mapController.addOverlay(_selectedCircleOverlay!);
    }
  }

  void _moveCameraTo(double lat, double lng) {
    _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(NCameraPosition(target: NLatLng(lat, lng), zoom: 16)),
    );
  }

  void _updateBorderOverlay(double lat, double lng) {
    _mapController.clearOverlays(type: NOverlayType.circleOverlay);
    _selectedCircleOverlay = NCircleOverlay(
      id: "selected_circle",
      center: NLatLng(lat, lng),
      radius: 30,
      color: Colors.blue.withOpacity(0.3),
      outlineColor: Colors.blue,
      outlineWidth: 2,
    );
    _mapController.addOverlay(_selectedCircleOverlay!);
  }

  void _selectSearchedStop(dynamic stop) {
    double lat = stop['latitude'];
    double lng = stop['longitude'];
    String nodeId = stop['nodeId'] ?? '';
    String nodeNm = stop['nodeNm'] ?? '';
    setState(() {
      _selectedMarkerId = nodeId;
    });

    // 바텀시트의 검색어를 설정하여 해당 정류장으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stopListBottomSheetKey.currentState?.setSearchQuery(nodeNm);
    });

    _moveCameraTo(lat, lng);
    _updateBorderOverlay(lat, lng);
  }

  // 도착 정보 가져오는 함수 (StopListBottomSheet에 전달)
  Future<List<dynamic>> _fetchStopArrivalInfo(String nodeId) async {
    try {
      return await _busApiService.fetchStopTime(nodeId);
    } catch (e) {
      _showErrorSnackBar("도착 정보를 가져오는데 실패했습니다: $e");
      throw e;
    }
  }

  // 바텀시트 높이 변경 콜백
  void _onBottomSheetHeightChanged(double height) {
    setState(() {
      _bottomSheetHeight = height;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 네이버 지도 (전체 화면 크기로 고정)
          SizedBox.expand(
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(35.3088233, 128.5185542),
                  zoom: 14,
                ),
                logoAlign: NLogoAlign.leftTop,
              ),
              onMapReady: (controller) async {
                _mapController = controller;
                // 맵 컨트롤러가 준비되면 정류장 데이터 가져오기
                await _fetchAndDisplayPath();
              },
            ),
          ),

          // 뒤로가기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ]
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),

          // 바텀시트 - AnimatedContainer 사용하여 부드러운 애니메이션 구현
          if (_allStops.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut, // 부드러운 애니메이션 커브 적용
                height: _bottomSheetHeight,
                child: StopListBottomSheet(
                  key: _stopListBottomSheetKey,
                  allStops: _allStops,
                  selectedMarkerId: _selectedMarkerId,
                  onStopSelected: _selectSearchedStop,
                  onRefresh: _fetchAndDisplayPath,
                  isLoading: _isLoading,
                  scaffoldKey: _scaffoldKey,
                  fetchArrivalInfo: _fetchStopArrivalInfo,
                  onHeightChanged: _onBottomSheetHeightChanged,
                ),
              ),
            ),

          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Color(0xFF2196F3))),
        ],
      ),
    );
  }

  Future<void> _fetchAndDisplayPath() async {
    try {
      setState(() => _isLoading = true);
      List<dynamic> response = await _busApiService.fetchPath();
      if (response.isEmpty || _mapController == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _allStops = response);

      Set<NMarker> newStopMarkers = response.map((stop) {
        final marker = createStopMarker(stop, onTap: () async {
          // 마커 선택 상태 업데이트
          setState(() => _selectedMarkerId = stop['nodeId']);

          // 카메라 이동 및 원형 오버레이 표시
          _moveCameraTo(stop['latitude'], stop['longitude']);
          _updateBorderOverlay(stop['latitude'], stop['longitude']);

          // 바텀시트의 상태 업데이트
          final String nodeNm = stop['nodeNm'] ?? '';

          // 검색어 업데이트 전에 잠시 지연을 줌 (상태 업데이트가 안정화되도록)
          Future.delayed(Duration(milliseconds: 100), () {
            // 바텀시트의 검색어 업데이트
            if (_stopListBottomSheetKey.currentState != null) {
              _stopListBottomSheetKey.currentState?.setSearchQuery(nodeNm);
            }
          });
        });
        return marker;
      }).toSet();

      setState(() {
        _stopMarkers = newStopMarkers;
        _isLoading = false;
      });

      _renderAllMarkers();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("정류장 정보를 가져오는데 실패했습니다: $e");
      print("정류장 마커 표시 실패: $e");
    }
  }
}