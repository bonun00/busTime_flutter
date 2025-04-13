import 'package:flutter/material.dart';
import '../main_widgets/searchable_dropdown.dart';
import '../../services/BusApiService.dart';
import '../../pages/main_page.dart';

class TopBanner extends StatefulWidget {
  final String currentRouteType;
  final List<String> chilwonStops;
  final List<String> masanStops;
  final String? selectedDeparture;
  final String? selectedArrival;
  final Function(String?) onDepartureChanged;
  final Function(String?) onArrivalChanged;
  final VoidCallback onToggleRouteType;
  final VoidCallback onSearch;
  final BusApiService busApiService;

  const TopBanner({
    Key? key,
    required this.currentRouteType,
    required this.chilwonStops,
    required this.masanStops,
    required this.selectedDeparture,
    required this.selectedArrival,
    required this.onDepartureChanged,
    required this.onArrivalChanged,
    required this.onToggleRouteType,
    required this.onSearch,
    required this.busApiService,
  }) : super(key: key);

  @override
  _TopBannerState createState() => _TopBannerState();
}

class _TopBannerState extends State<TopBanner> {
  List<String> _availableDestinations = [];
  bool _isLoadingDestinations = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDeparture != null) {
      _loadAvailableDestinations(widget.selectedDeparture!);
    }
  }

  @override
  void didUpdateWidget(TopBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDeparture != oldWidget.selectedDeparture) {
      if (widget.selectedDeparture != null) {
        _loadAvailableDestinations(widget.selectedDeparture!);
      } else {
        setState(() {
          _availableDestinations = [];
        });
      }
    }

    if (widget.currentRouteType != oldWidget.currentRouteType && widget.selectedDeparture != null) {
      _loadAvailableDestinations(widget.selectedDeparture!);
    }
  }

  Future<void> _loadAvailableDestinations(String departureStop) async {
    setState(() {
      _isLoadingDestinations = true;
      _availableDestinations = []; // 로딩 시작할 때 목록 초기화
    });

    try {
      List<String> availableStops = [];

      if (widget.currentRouteType == 'chilwon') {
        final allStops = List<String>.from(widget.chilwonStops);
        for (var arrivalStop in allStops) {
          // 자기 자신으로의 경로는 제외
          if (arrivalStop != departureStop) {
            final schedules = await widget.busApiService.fetchChilwonRouteSchedules(
                departureStop, arrivalStop
            );
            if (schedules.isNotEmpty) {
              availableStops.add(arrivalStop);
            }
          }
        }
      } else {
        final allStops = List<String>.from(widget.masanStops);
        for (var arrivalStop in allStops) {
          if (arrivalStop != departureStop) {
            final schedules = await widget.busApiService.fetchMasanRouteSchedules(
                departureStop, arrivalStop
            );
            if (schedules.isNotEmpty) {
              availableStops.add(arrivalStop);
            }
          }
        }
      }

      setState(() {
        _availableDestinations = availableStops;
        _isLoadingDestinations = false;

        // 선택된 도착지가 새로운 가능한 목록에 없는 경우 초기화
        if (widget.selectedArrival != null &&
            !_availableDestinations.contains(widget.selectedArrival)) {
          widget.onArrivalChanged(null);
        }
      });
    } catch (e) {
      print('도착지 로딩 에러: $e');
      setState(() {
        _isLoadingDestinations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 노선 유형에 따라 배경색 변경
    final bannerColor = (widget.currentRouteType == 'chilwon')
        ? [Color(0xFF1976D2), Color(0xFF1565C0)]
        : [Color(0xFF388E3C), Color(0xFF2E7D32)];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bannerColor,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // 배경 아이콘
          Positioned(
            right: -20,
            bottom: -10,
            child: Icon(
              Icons.directions_bus,
              size: 140, // 버스 아이콘 크기 증가
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 34), // 여백 증가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 노선 유형 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 중앙(혹은 중간) 텍스트
                    Expanded(
                      child: Text(
                        (widget.currentRouteType == 'chilwon')
                            ? '칠원 방면 노선 검색'
                            : '마산 방면 노선 검색',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 26, // 글자 크기 증가 (24→26)
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 노선 전환 아이콘 버튼
                    IconButton(
                      icon: Icon(Icons.swap_horiz, color: Colors.white, size: 28), // 아이콘 크기 증가
                      iconSize: 28, // 아이콘 터치 영역 증가
                      tooltip: '노선 전환 (칠원 ↔ 마산)',
                      onPressed: widget.onToggleRouteType,
                      padding: EdgeInsets.all(12), // 버튼 패딩 증가
                    ),
                  ],
                ),
                SizedBox(height: 10), // 간격 증가

                // 드롭다운 2개 + 검색 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14), // 모서리 더 둥글게
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20), // 패딩 증가 (16→20)
                  child: Column(
                    children: [
                      // 출발 정류장 검색 가능한 Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.trip_origin, color: Color(0xFF388E3C), size: 26), // 아이콘 크기 증가
                          SizedBox(width: 14), // 간격 증가
                          Expanded(
                            child: Theme(
                              // 드롭다운 내부 텍스트 스타일 조정
                              data: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.copyWith(
                                  titleMedium: TextStyle(fontSize: 18), // 드롭다운 내부 텍스트 크기 증가
                                ),
                              ),
                              child: SearchableDropdown(
                                hint: '출발 정류장',
                                value: widget.selectedDeparture,
                                items: (widget.currentRouteType == 'chilwon'
                                    ? widget.chilwonStops
                                    : widget.masanStops),
                                onChanged: (value) {
                                  widget.onDepartureChanged(value);
                                  // 출발지 변경 시 도착지 자동 초기화는 didUpdateWidget에서 처리
                                },
                                iconColor: Color(0xFF388E3C)
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24), // 간격 증가 (20→24)

                      // 도착 정류장 검색 가능한 Dropdown (수정된 부분)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF1976D2), size: 26), // 아이콘 크기 증가
                          SizedBox(width: 14), // 간격 증가
                          Expanded(
                            child: Stack(
                              children: [
                                // 수정된 드롭다운 (필터링된 목록 사용)
                                Theme(
                                  // 드롭다운 내부 텍스트 스타일 조정
                                  data: Theme.of(context).copyWith(
                                    textTheme: Theme.of(context).textTheme.copyWith(
                                      titleMedium: TextStyle(fontSize: 18), // 드롭다운 내부 텍스트 크기 증가
                                    ),
                                  ),
                                  child: SearchableDropdown(
                                    hint: _getDestinationHint(),
                                    value: widget.selectedArrival,
                                    items: _availableDestinations,
                                    onChanged: widget.onArrivalChanged,
                                    iconColor: Color(0xFF1976D2),
                                  ),
                                ),

                                // 로딩 표시기
                                if (_isLoadingDestinations)
                                  Positioned(
                                    right: 40,
                                    top: 10,
                                    child: SizedBox(
                                      width: 22, // 로딩 표시기 크기 증가
                                      height: 22, // 로딩 표시기 크기 증가
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3, // 선 두께 증가
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28), // 간격 증가 (20→28)

                      // 시간표 검색 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 54, // 버튼 높이 증가 (기존보다 높게)
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (widget.currentRouteType == 'chilwon')
                                ? Color(0xFF1976D2)
                                : Color(0xFF388E3C),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // 모서리 더 둥글게
                            ),
                            elevation: 3, // 그림자 효과 증가
                          ),
                          onPressed: _canSearch() ? widget.onSearch : null,
                          child: Text(
                            '시간표 검색',
                            style: TextStyle(
                              fontSize: 20, // 버튼 텍스트 크기 증가
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 도착지 드롭다운의 힌트 메시지 결정
  String _getDestinationHint() {
    if (widget.selectedDeparture == null) {
      return '출발지를 먼저 선택해주세요';
    }

    if (_isLoadingDestinations) {
      return '도착 가능한 정류장 확인 중...';
    }

    if (_availableDestinations.isEmpty) {
      return '해당 출발지에서 운행 가능한 노선이 없습니다';
    }

    return '도착 정류장';
  }

  // 검색 버튼 활성화 여부 결정
  bool _canSearch() {
    return widget.selectedDeparture != null &&
        widget.selectedArrival != null &&
        !_isLoadingDestinations;
  }
}