import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/BusApiService.dart';
import '../widgets/top_banner.dart';
import '../widgets/search_results_section.dart';
import '../widgets/route_card.dart';
import '../widgets/live_tracking.dart';
import '../widgets/info_card.dart';
import '../widgets/section_title.dart';
import '../pages/favorite_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ------------------------------
  // 1) 드롭다운으로 쓸 정류장 목록
  // ------------------------------
  List<String> _chilwonStops = []; // 칠원 정류장 목록
  List<String> _masanStops = [];   // 마산 정류장 목록

  // ------------------------------
  // 2) 출발·도착 정류장 선택값
  // ------------------------------
  String? _selectedDeparture; // 출발 정류장 이름
  String? _selectedArrival;   // 도착 정류장 이름

  // ------------------------------
  // 3) 시간표 조회 결과
  // ------------------------------
  List<Map<String, dynamic>> _schedules = [];

  // ------------------------------
  // 4) 로딩 & 결과 표시
  // ------------------------------
  bool _isLoading = false;
  bool _showResults = false;

  // ------------------------------
  // 5) 노선 유형 (chilwon or masan)
  // ------------------------------
  String _currentRouteType = 'chilwon'; // 초기값: 칠원 노선

  // ------------------------------
  // 6) Bus API Service
  // ------------------------------
  final BusApiService _busApiService = BusApiService();

  // ------------------------------
  // initState: 정류장 목록 불러오기
  // ------------------------------
  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  // ------------------------------
  // (A) 정류장 목록 로딩
  // ------------------------------
  Future<void> _loadStops() async {
    try {
      final chilwonList = await _busApiService.fetchChilwonStops();
      final masanList   = await _busApiService.fetchMasanStops();

      // 응답이 [{"stopName":"칠원정류장1"}, ...] 형태라면, 'stopName' 추출
      final chilwonStopsConverted = chilwonList.map((e) {
        // e는 Map<String, dynamic>
        return e['stopName'].toString();
      }).toList();

      final masanStopsConverted = masanList.map((e) {
        return e['stopName'].toString();
      }).toList();

      setState(() {
        _chilwonStops = List<String>.from(chilwonStopsConverted);
        _masanStops   = List<String>.from(masanStopsConverted);
      });
    } catch (e) {
      print("정류장 목록 로딩 실패: $e");
    }
  }

  // ------------------------------
  // (B) 시간표 조회 (이름 기반)
  // ------------------------------
  Future<void> _fetchSchedulesByName() async {
    if (_selectedDeparture == null || _selectedArrival == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("출발지와 도착지를 모두 선택해주세요!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = false; // 새로 조회 시 결과창 닫았다가, 성공 후 표시
    });

    try {
      List<dynamic> result = [];

      if (_currentRouteType == 'chilwon') {
        // 예: GET /route-chilwon-schedules?departureStop=xxx&arrivalStop=yyy
        result = await _busApiService.fetchChilwonRouteSchedules(
          _selectedDeparture!,
          _selectedArrival!,
        );
      } else {
        // 예: GET /route-masan-schedules?departureStop=xxx&arrivalStop=yyy
        result = await _busApiService.fetchMasanRouteSchedules(
          _selectedDeparture!,
          _selectedArrival!,
        );
      }

      // List<dynamic> -> List<Map<String, dynamic>>
      final schedules = result.map<Map<String, dynamic>>((e) => Map<String,dynamic>.from(e)).toList();

      setState(() {
        _schedules = schedules;
        _isLoading = false;
        _showResults = true; // 결과 표시
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("시간표 불러오기 실패: $e")),
      );
    }
  }

  // ------------------------------
  // (C) 노선 유형 토글 (칠원 ↔ 마산)
  // ------------------------------
  void _toggleRouteType() {
    setState(() {
      // chilwon <-> masan 전환
      _currentRouteType =
      (_currentRouteType == 'chilwon') ? 'masan' : 'chilwon';

      // 검색값/선택값 리셋
      _showResults = false;
      _selectedDeparture = null;
      _selectedArrival   = null;
      _schedules.clear();
    });
  }

  // ------------------------------
  // BUILD
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar
      appBar: AppBar(
        backgroundColor:(_currentRouteType == 'chilwon')
            ? Color(0xFF1976D2) : Color(0xFF388E3C),
        elevation: 0,
        // 왼쪽: 로고 + 텍스트
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () async{
              final result=await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );


    // 즐겨찾기 화면에서 경로를 선택했을 때 처리
    if (result != null && result is Map<String, dynamic>) {
      // 선택한 경로로 검색 설정
      setState(() {
        // 선택한 노선 타입으로 변경
        _currentRouteType = result['routeType'];

        // 선택한 출발지/도착지 설정
        _selectedDeparture = result['departure'];
        _selectedArrival = result['arrival'];
      });
    }
            },
          ),
        ],
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (_currentRouteType == 'chilwon')
                    ?Color(0xFF388E3C)
                    : Color(0xFF1976D2) ,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.directions_bus, color: Colors.white, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              '농어촌 버스(마산 <->함안)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // (1) 상단 배너
            TopBanner(
              currentRouteType: _currentRouteType,
              chilwonStops: _chilwonStops,
              masanStops: _masanStops,
              selectedDeparture: _selectedDeparture,
              selectedArrival: _selectedArrival,
              onDepartureChanged: (value) {
                setState(() {
                  _selectedDeparture = value;
                });
              },
              onArrivalChanged: (value) {
                setState(() {
                  _selectedArrival = value;
                });
              },
              onToggleRouteType: _toggleRouteType,
              onSearch: _fetchSchedulesByName,
              busApiService:_busApiService,
            ),

            // (2) 메인 콘텐츠
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 검색 결과 섹션
                  if (_showResults) ...[
                    SearchResultsSection(
                      busApiService: _busApiService,
                      currentRouteType: _currentRouteType,
                      selectedDeparture: _selectedDeparture,
                      selectedArrival: _selectedArrival,
                      schedules: _schedules,
                      isLoading: _isLoading,
                      onClose: () {
                        setState(() {
                          _showResults = false;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                  ],

                  // 노선 선택 섹션
                  SectionTitle(title: '노선 선택'),
                  SizedBox(height: 16),
                  RouteCard(
                    title: '칠원 → 마산',
                    subtitle: '마산 방면 노선',
                    icon: Icons.directions_bus,
                    color: Color(0xFF388E3C),
                    routeName: '/location-filter2',
                  ),
                  SizedBox(height: 12),
                  RouteCard(
                    title: '마산 → 칠원',
                    subtitle: '칠원 방면 노선',
                    icon: Icons.directions_bus_filled,
                    color: Color(0xFF1976D2),
                    routeName: '/location-filter',
                  ),
                  SizedBox(height: 24),

                  // 실시간 정보
                  SectionTitle(title: '실시간 정보'),
                  SizedBox(height: 16),
                  LiveTracking(),
                  SizedBox(height: 24),

                  // 안내사항
                  SectionTitle(title: '안내사항'),
                  SizedBox(height: 16),
                  InfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}