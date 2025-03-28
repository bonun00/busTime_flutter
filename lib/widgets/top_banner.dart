import 'package:flutter/material.dart';
import 'searchable_dropdown.dart';

class TopBanner extends StatelessWidget {
  final String currentRouteType;
  final List<String> chilwonStops;
  final List<String> masanStops;
  final String? selectedDeparture;
  final String? selectedArrival;
  final Function(String?) onDepartureChanged;
  final Function(String?) onArrivalChanged;
  final VoidCallback onToggleRouteType;
  final VoidCallback onSearch;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 노선 유형에 따라 배경색 변경
    final bannerColor = (currentRouteType == 'chilwon')
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
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                        (currentRouteType == 'chilwon')
                            ? '칠원 방면 노선 검색'
                            : '마산 방면  노선 검색',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 노선 전환 아이콘 버튼
                    IconButton(
                      icon: Icon(Icons.swap_horiz, color: Colors.white),
                      tooltip: '노선 전환 (칠원 ↔ 마산)',
                      onPressed: onToggleRouteType,
                    ),
                  ],
                ),
                SizedBox(height: 6),

                // 드롭다운 2개 + 검색 버튼
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 출발 정류장 검색 가능한 Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.trip_origin, color: Color(0xFF388E3C)),
                          SizedBox(width: 10),
                          Expanded(
                            child: SearchableDropdown(
                              hint: '출발 정류장',
                              value: selectedDeparture,
                              items: (currentRouteType == 'chilwon'
                                  ? chilwonStops
                                  : masanStops),
                              onChanged: onDepartureChanged,
                              iconColor: Color(0xFF388E3C),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // 도착 정류장 검색 가능한 Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF1976D2)),
                          SizedBox(width: 10),
                          Expanded(
                            child: SearchableDropdown(
                              hint: '도착 정류장',
                              value: selectedArrival,
                              items: (currentRouteType == 'chilwon'
                                  ? chilwonStops
                                  : masanStops),
                              onChanged: onArrivalChanged,
                              iconColor: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // 시간표 검색 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (currentRouteType == 'chilwon')
                                ?Color(0xFF1976D2)
                                :  Color(0xFF388E3C),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onSearch,
                          child: Text('시간표 검색'),
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
}