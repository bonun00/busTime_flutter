// main 화면 파일 (screens/naver_map_screen.dart)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/map_widgets/stop_search_bar.dart';
import '../widgets/map_widgets/bus_info_panel.dart';
import '../widgets/map_widgets/bottom_sheets.dart';
import '../widgets/map_widgets/map_marker.dart';
import '../services/stomp_manager.dart';
import '../services/BusApiService.dart';
// main 화면 파일 (screens/nave

class NaverMapScreen extends StatefulWidget {
  @override
  _NaverMapScreenState createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> with SingleTickerProviderStateMixin {
  StompManager _stompManager = StompManager();
  late NaverMapController _mapController;
  Set<NMarker> _busMarkers = {};
  Set<NMarker> _stopMarkers = {};
  List<dynamic> _busList = [];
  List<dynamic> _allStops = [];
  List<dynamic> _searchResults = [];
  String? _selectedMarkerId;
  NCircleOverlay? _selectedCircleOverlay;
  bool _isLoading = true;
  late AnimationController _animationController;
  bool _isListExpanded = true;
  String _selectedRegion = 'masan';
  final BusApiService _busApiService = BusApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  double _busPanelHeight = 250.0;
  double _minPanelHeight = 60.0;
  double _maxPanelHeight = 500.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _connectStomp();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  void _connectStomp() {
    setState(() {
      _isLoading = true;
    });
    _stompManager.connect(
      region: _selectedRegion,
      onBusDataReceived: _updateBusData,
      onError: (msg) => _showErrorSnackBar(msg),
      onConnected: () => setState(() => _isLoading = false),
    );
  }

  void _changeRegion(String region) {
    setState(() {
      _selectedRegion = region;
      _busMarkers.clear();
      _stopMarkers.clear();
      _busList.clear();
      _isLoading = true;
    });
    _connectStomp();
    _fetchAndDisplayPath(region == 'masan' ? '마산' : '칠원');
  }

  void _updateBusData(List<dynamic> buses) {
    setState(() {
      _busList = buses;
      _busMarkers = buses.map((bus) => createBusMarker(bus, onTap: () {
        setState(() => _selectedMarkerId = bus['vehicleId'].toString());
        _moveCameraTo(double.parse(bus['latitude'].toString()), double.parse(bus['longitude'].toString()));
        _updateBorderOverlay(double.parse(bus['latitude'].toString()), double.parse(bus['longitude'].toString()));
        showBusInfoBottomSheet(context, bus);
      })).toSet();
    });
    _renderAllMarkers();
  }

  void _renderAllMarkers() async {
    if (_mapController == null) return;
    if (_stopMarkers.isEmpty && _busMarkers.isEmpty) return;
    await _mapController.clearOverlays();
    await _mapController.addOverlayAll({..._stopMarkers, ..._busMarkers});
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
      color: Colors.red.withOpacity(0.3),
      outlineColor: Colors.red,
      outlineWidth: 2,
    );
    _mapController.addOverlay(_selectedCircleOverlay!);
  }

  void _searchStops(String query) {
    print('🔍 검색어: $query');
    print('🧾 전체 정류장 수: ${_allStops.length}');

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

    print('✅ 검색 결과 수: ${_searchResults.length}');
  }

  void _selectSearchedStop(dynamic stop) {
    double lat = stop['latitude'];
    double lng = stop['longitude'];
    String nodeNm = stop['nodeNm'] ?? '';
    String nodeId = stop['nodeId'] ?? '';

    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });
    _moveCameraTo(lat, lng);
    _updateBorderOverlay(lat, lng);
    _busApiService.fetchStopTime(nodeId).then((arrivalInfo) {
      showStopArrivalSheet(context, nodeNm, arrivalInfo);
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
    _stompManager.disconnect();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('실시간 버스', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
        ],
      ),

      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
          child: buildSearchBar(
            context,
            _searchController,
            _searchResults,
            _isSearching,
            onSearchChanged: _searchStops,
            onStopSelected: _selectSearchedStop,
            onClear: () => _clearSearch(),
          ),
          ),

          Positioned(
            top: _isSearching ? 360 : 60, // 검색 결과 있을 땐 더 내려줌!
            left: 0,
            right: 0,
            bottom: 0,
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(35.3088233, 128.5185542),
                  zoom: 14,
                ),
              ),
              onMapReady: (controller) async {
                _mapController = controller;
                await _fetchAndDisplayPath(_selectedRegion == 'masan' ? '마산' : '칠원');
              },
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Color(0xFF388E3C))),
          if (!_isSearching)
            BusListPanel(
              busList: _busList,
              selectedId: _selectedMarkerId,
              onSelect: (bus) {
                setState(() => _selectedMarkerId = bus['vehicleId']);
                _moveCameraTo(double.parse(bus['latitude']), double.parse(bus['longitude']));
                _updateBorderOverlay(double.parse(bus['latitude']), double.parse(bus['longitude']));
              },
            )
        ],
      ),
    );
  }

  Future<void> _fetchAndDisplayPath(String direction) async {
    try {
      List<dynamic> response = await _busApiService.fetchPath(direction);
      if (response.isEmpty || _mapController == null) return;
      setState(() => _allStops = response);
      Set<NMarker> newStopMarkers = response.map((stop) {
        final marker = createStopMarker(stop, onTap: () async {
          final arrivalInfo = await _busApiService.fetchStopTime(stop['nodeId']);
          showStopArrivalSheet(context, stop['nodeNm'], arrivalInfo);
        });
        return marker;
      }).toSet();
      setState(() => _stopMarkers = newStopMarkers);
      _renderAllMarkers();
    } catch (e) {
      print("정류장 마커 표시 실패: $e");
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults = [];
    });
  }
}
