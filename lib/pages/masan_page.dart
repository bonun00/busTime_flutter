import 'package:flutter/material.dart';
import '../services/BusApiService.dart';
import '../widgets/route_widgets/bus_selection_chips.dart';
import '../widgets/route_widgets/stop_search_field.dart';
import '../widgets/route_widgets/time_filter_chips.dart';
import '../widgets/route_widgets/selected_stop_display.dart';
import '../widgets/route_widgets/stop_list.dart';
import '../widgets/route_widgets/schedule_list.dart';
import '../widgets/route_widgets/empty_state.dart';
import '../widgets/route_widgets/loading_state.dart';
import '../widgets/route_widgets/refresh_controller.dart';

class masan extends StatefulWidget {
  @override
  _masanState createState() => _masanState();
}

class _masanState extends State<masan> with TickerProviderStateMixin {
  final BusApiService _busApiService = BusApiService();

  // 데이터 관련 변수
  Map<String, List<dynamic>> _busSchedules = {}; // 버스별 시간표
  Map<String, List<dynamic>> _busRoutes = {}; // 노선 데이터 저장
  List<String> _stops = [];
  bool _isLoading = false;
  String? _selectedStop;
  String? _expandedTimeId;

  // 버스 선택 관련 변수
  final List<String> _busNumbers = ['113', '250'];
  final Map<String, Color> _busColors = {
    '113': Color(0xFF388E3C),
    '250': Color(0xFF1976D2),
  };
  Set<String> _selectedBusNumbers = {};

  // 애니메이션 컨트롤러
  late AnimationController _expandController;

  // 시간대별 표시 필터
  String _timeFilter = '전체';
  final List<String> _timeFilters = ['전체', '오전', '오후', '저녁'];
  bool _showUpcomingOnly = false;

  // 정류장 검색
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredStops = [];
  bool _isSearching = false;

  // 새로고침 컨트롤러
  RefreshController _refreshController = RefreshController();

  // 기본 색상 (메인 테마와 일치시킴)
  Color get _defaultColor => Color(0xFF388E3C); // 메인 그린 색상

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _expandController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    // 초기 데이터 로드
    _loadStops();

    // 검색 컨트롤러 리스너 설정
    _searchController.addListener(_filterStops);
  }

  @override
  void dispose() {
    _expandController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // 정류장 목록 불러오기
  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> stops = await _busApiService.fetchMasanStops();
      setState(() {
        _stops = stops.map((e) => e['stopName'].toString()).toList();
        _filteredStops = List.from(_stops);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("정류장 정보를 불러오는데 실패했습니다.");
    }
  }

  // 정류장 검색 필터
  void _filterStops() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredStops = List.from(_stops);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _filteredStops = _stops
          .where((stop) => stop.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
      _isSearching = true;
    });
  }

  // 버스 번호 선택/해제
  void _toggleBusSelection(String busNumber) {
    setState(() {
      if (_selectedBusNumbers.contains(busNumber)) {
        _selectedBusNumbers.remove(busNumber);
        _busSchedules.remove(busNumber);
      } else {
        _selectedBusNumbers.add(busNumber);
        if (_selectedStop != null) {
          _fetchBusSchedule(busNumber);
        }
      }
    });
  }

  // 모든 선택된 버스의 시간표 불러오기
  Future<void> _fetchAllBusSchedules() async {
    if (_selectedBusNumbers.isEmpty || _selectedStop == null) {
      _showSnackBar("버스 번호와 정류장을 선택해주세요.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (String busNumber in _selectedBusNumbers) {
        await _fetchBusSchedule(busNumber);
      }

      setState(() {
        _isLoading = false;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _refreshController.refreshFailed();
      _showSnackBar("시간표를 불러오는데 실패했습니다.");
    }
  }
// 개별 버스의 시간표 불러오기
  Future<void> _fetchBusSchedule(String busNumber) async {
    if (_selectedStop == null) return;

    try {
      List<dynamic> schedule = await _busApiService.fetchMasanTimes(busNumber, _selectedStop!);

      // API에서 받은 원래 버스 번호를 보존하기 위해 데이터 처리
      List<Map<String, dynamic>> processedSchedule = [];

      for (var item in schedule) {
        // item을 Map<String, dynamic>으로 변환
        Map<String, dynamic> scheduleItem = Map<String, dynamic>.from(item);

        // API에서 반환된 원본 버스 번호 저장 (예: 113-31)
        String originalBusNumber = scheduleItem['busNumber'];

        // 디스플레이용 간단한 버스 번호 추가 (예: 113)
        // 필요한 경우 다른 로직으로 변경 가능
        scheduleItem['displayBusNumber'] = busNumber;

        processedSchedule.add(scheduleItem);
      }

      setState(() {
        _busSchedules[busNumber] = processedSchedule;
      });

      print("버스 시간표 로드 완료: $busNumber, 항목 수: ${processedSchedule.length}");
    } catch (e) {
      print("시간표 불러오기 에러: $e");
      _showSnackBar("$busNumber번 버스 시간표를 불러오는데 실패했습니다.");
    }
  }

// 모든 선택된 버스의 시간표를 통합 및 시간별 정렬
  List<Map<String, dynamic>> get _combinedSchedule {
    List<Map<String, dynamic>> combinedList = [];

    // 모든 선택된 버스의 시간표를 통합
    _selectedBusNumbers.forEach((busNumber) {
      if (_busSchedules.containsKey(busNumber)) {
        _busSchedules[busNumber]!.forEach((schedule) {
          // 원본 버스 번호가 있는지 확인
          String originalBusNumber = schedule['busNumber'] ?? busNumber;

          combinedList.add({
            ...Map<String, dynamic>.from(schedule),
            'busNumber': busNumber, // 디스플레이용 간단한 버스 번호
            'originalBusNumber': originalBusNumber, // API에서 받은 원본 버스 번호
          });
        });
      }
    });

    // 시간 기준으로 정렬
    combinedList.sort((a, b) {
      String timeA = _formatTime(a['arrivalTime']);
      String timeB = _formatTime(b['arrivalTime']);
      return timeA.compareTo(timeB);
    });

    return combinedList;
  }


  // 상세 노선 불러오기
  Future<void> _fetchBusRoute(String timeId, String time, String busNumber) async {
    // 이미 펼쳐진 항목 클릭 시 닫기
    if (_expandedTimeId == timeId) {
      setState(() {
        _expandedTimeId = null;
      });
      return;
    }

    // 다른 항목이 펼쳐져 있는 경우 닫기
    if (_expandedTimeId != null) {
      setState(() {
        _expandedTimeId = null;
      });
      await Future.delayed(Duration(milliseconds: 200));
    }

    // 시간을 HH:mm:00 형식으로 변환
    String sendTime = time + ":00";

    // 노선 정보가 없는 경우 API에서 가져오기
    if (!_busRoutes.containsKey(timeId)) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<dynamic> route = await _busApiService.fetchMasanRoute(busNumber, sendTime);
        print("노선 정보 불러오기 성공: $timeId");
        print("노선 데이터: $route");
        setState(() {
          _busRoutes[timeId] = route;
          _isLoading = false;
          _expandedTimeId = timeId;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar("노선 정보를 불러오는데 실패했습니다.");
      }
    } else {
      setState(() {
        _expandedTimeId = timeId;
      });
    }
  }

  // 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF388E3C), // 메인 그린 색상으로 변경
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // 시간을 HH:mm 형식으로 표시
  String _formatTime(String time) {
    return time.length >= 5 ? time.substring(0, 5) : time;
  }



  // 시간별 필터링된 일정 가져오기
  List<Map<String, dynamic>> get _filteredSchedule {
    List<Map<String, dynamic>> result = List.from(_combinedSchedule);

    // 시간대로 필터링
    if (_timeFilter != '전체') {
      result = result.where((bus) {
        String time = _formatTime(bus['arrivalTime']);
        int hour = int.tryParse(time.split(':')[0]) ?? 0;

        if (_timeFilter == '오전') return hour >= 5 && hour < 12;
        if (_timeFilter == '오후') return hour >= 12 && hour < 18;
        if (_timeFilter == '저녁') return hour >= 18 || hour < 5;

        return true;
      }).toList();
    }

    // 현재 시간 이후만 필터링
    if (_showUpcomingOnly) {
      final now = DateTime.now();
      result = result.where((bus) {
        String time = _formatTime(bus['arrivalTime']);
        List<String> parts = time.split(':');
        if (parts.length != 2) return false;

        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;

        return (hour > now.hour) || (hour == now.hour && minute >= now.minute);
      }).toList();
    }

    return result;
  }

  // 정류장 선택 화면
  Widget _buildStopSelectionView() {
    if (_isLoading) {
      return LoadingState(color: _defaultColor);
    }

    return _stops.isEmpty
        ? EmptyState(
      title: '정류장 정보가 없습니다',
      subtitle: '다시 시도해주세요',
      buttonText: '새로고침',
      onButtonPressed: _loadStops,
      iconColor: _defaultColor,
    )
        : StopList(
      stops: _filteredStops,
      onStopSelected: (stop) {
        setState(() {
          _selectedStop = stop;
          _searchController.clear();
          _isSearching = false;
        });

        if (_selectedBusNumbers.isNotEmpty) {
          _fetchAllBusSchedules();
        }
      },
      themeColor: _defaultColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: _defaultColor, // 헤더 배경색을 그린으로 변경
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF388E3C), Color(0xFF2E7D32)], // 그라데이션 추가
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16, 95, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '칠원 → 마산',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: 36),
                        child: Text(
                          '정확한 버스 시간표 정보를 확인하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    if (_selectedStop != null) {
                      _fetchAllBusSchedules();
                    } else {
                      _loadStops();
                    }
                  },
                ),
              ],
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // 버스 선택 칩
              BusSelectionChips(
                busNumbers: _busNumbers,
                selectedBusNumbers: _selectedBusNumbers,
                busColors: _busColors,
                onBusSelected: _toggleBusSelection,
                themeColor: _defaultColor,
              ),

              // 정류장 검색 필드
              StopSearchField(
                controller: _searchController,
                themeColor: _defaultColor,
              ),

              // 시간대 필터 선택 칩
              if (_selectedStop != null && _combinedSchedule.isNotEmpty)
                TimeFilterChips(
                  timeFilters: _timeFilters,
                  selectedFilter: _timeFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      _timeFilter = filter;
                    });
                  },
                  themeColor: _defaultColor,
                  showUpcomingOnly: _showUpcomingOnly,
                  onUpcomingToggled: (value) {
                    setState(() {
                      _showUpcomingOnly = value;
                    });
                  },
                ),

              // 선택된 정류장 표시
              if (_selectedStop != null)
                SelectedStopDisplay(
                  stopName: _selectedStop!,
                  onClose: () {
                    setState(() {
                      _selectedStop = null;
                      _busSchedules.clear();
                    });
                  },
                  themeColor: _defaultColor,
                ),

              // 메인 콘텐츠
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: _isSearching && _searchController.text.isNotEmpty
                      ? StopList(
                    stops: _filteredStops,
                    onStopSelected: (stop) {
                      setState(() {
                        _selectedStop = stop;
                        _searchController.clear();
                        _isSearching = false;
                      });

                      if (_selectedBusNumbers.isNotEmpty) {
                        _fetchAllBusSchedules();
                      }
                    },
                    themeColor: _defaultColor,
                  )
                      : _selectedStop == null
                      ? _buildStopSelectionView()
                      : _buildScheduleContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 스케줄 컨텐츠 빌드
  Widget _buildScheduleContent() {
    if (_isLoading) {
      return LoadingState(color: _defaultColor);
    }

    if (_selectedBusNumbers.isEmpty) {
      return EmptyState(
        title: '버스를 선택해주세요',
        subtitle: '위에서 버스 번호를 하나 이상 선택하세요',
        buttonText: '새로고침',
        onButtonPressed: _fetchAllBusSchedules,
        iconColor: _defaultColor,
      );
    }

    if (_combinedSchedule.isEmpty) {
      return EmptyState(
        title: '시간표 정보가 없습니다',
        subtitle: '다른 버스 번호나 정류장을 선택해보세요',
        buttonText: '새로고침',
        onButtonPressed: _fetchAllBusSchedules,
        iconColor: _defaultColor,
      );
    }

    // 필터링된 스케줄이 없을 때
    if (_filteredSchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 60,
              color: Colors.grey[300],
            ),
            SizedBox(height: 20),
            Text(
              '선택한 필터 조건에 맞는 시간표가 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _timeFilter = '전체';
                  _showUpcomingOnly = false;
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('필터 초기화'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _defaultColor,
              ),
            )
          ],
        ),
      );
    }

      return ScheduleList(
        busSchedules: _busSchedules,
        schedules: _filteredSchedule,
        expandedTimeId: _expandedTimeId,
        busColors: _busColors,
        busRoutes: _busRoutes,
        selectedStop: _selectedStop,
        defaultColor: _defaultColor,
        onTapSchedule: _fetchBusRoute,
        formatTime: _formatTime,
        onRefresh: _fetchAllBusSchedules,
        showUpcomingOnly: _showUpcomingOnly,
      );
  }
}