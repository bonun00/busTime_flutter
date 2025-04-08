import 'package:flutter/material.dart';
import '../services/BusApiService.dart';

// 1. 노선도 표시를 위한 위젯
class RouteMapWidget extends StatelessWidget {
  final List<dynamic> routeData;
  final String? selectedDeparture;
  final String? selectedArrival;
  final String busNumber;

  const RouteMapWidget({
    Key? key,
    required this.routeData,
    required this.busNumber,
    this.selectedDeparture,
    this.selectedArrival,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20), // 패딩 증가 (16→20)
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 패딩 증가
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가
                ),
                child: Text(
                  '$busNumber번',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // 글자 크기 증가
                  ),
                ),
              ),
              SizedBox(width: 12), // 간격 증가
              Text(
                '전체 노선도',
                style: TextStyle(
                  fontSize: 24, // 글자 크기 증가 (18→24)
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(thickness: 1.5), // 구분선 두께 증가
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // 패딩 증가 (16→20)
              child: _buildRouteTimeline(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteTimeline() {
    return Column(
      children: List.generate(routeData.length, (index) {
        final stop = routeData[index];
        final stopName = stop['stopName'] ?? '정류장 정보 없음';
        final arrivalTime = stop['arrivalTime'] ?? '--:--';
        final isLastStop = index == routeData.length - 1;

        // 현재 선택된 출발지/도착지와 일치하는지 확인
        final isSelectedDeparture = selectedDeparture != null && stopName == selectedDeparture;
        final isSelectedArrival = selectedArrival != null && stopName == selectedArrival;
        final isSelected = isSelectedDeparture || isSelectedArrival;

        // 선택된 정류장은 강조 표시
        final stopColor = isSelectedDeparture
            ? Color(0xFF388E3C)  // 출발지는 초록색
            : isSelectedArrival
            ? Color(0xFF1976D2)  // 도착지는 파란색
            : Colors.grey[600];  // 일반 정류장은 회색

        return Container(
          margin: EdgeInsets.only(bottom: isLastStop ? 0 : 12), // 마진 증가 (8→12)
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 타임라인 부분
                Container(
                  width: 30, // 너비 증가 (24→30)
                  child: Column(
                    children: [
                      // 정류장 점
                      Container(
                        width: 20, // 크기 증가 (16→20)
                        height: 20, // 크기 증가 (16→20)
                        decoration: BoxDecoration(
                          color: stopColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: stopColor!.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)] // 그림자 효과 증가
                              : null,
                        ),
                      ),
                      // 연결선
                      if (!isLastStop)
                        Expanded(
                          child: Container(
                            width: 3, // 너비 증가 (2→3)
                            margin: EdgeInsets.symmetric(vertical: 4),
                            color: Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                ),

                // 오른쪽 정류장 정보 부분
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, bottom: 20), // 마진 증가 (8,16→10,20)
                    padding: EdgeInsets.all(16), // 패딩 증가 (12→16)
                    decoration: BoxDecoration(
                      color: isSelected ? stopColor!.withOpacity(0.1) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글기 증가 (8→10)
                      border: Border.all(
                        color: isSelected ? stopColor! : Colors.grey[200]!,
                        width: isSelected ? 2 : 1.5, // 테두리 두께 증가
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                stopName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: isSelected ? 20 : 18, // 글자 크기 증가 (16,15→20,18)
                                  color: isSelected ? stopColor : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 패딩 증가 (6,2→8,4)
                                decoration: BoxDecoration(
                                  color: stopColor,
                                  borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
                                ),
                                child: Text(
                                  isSelectedDeparture ? '출발' : '도착',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // 글자 크기 증가 (10→14)
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8), // 간격 증가 (4→8)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18, // 아이콘 크기 증가 (14→18)
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 6), // 간격 증가 (4→6)
                                Text(
                                  '도착시간: $arrivalTime',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16, // 글자 크기 증가 (13→16)
                                  ),
                                ),
                              ],
                            ),

                            // 정류장 번호가 있다면 표시
                            if (stop['stopId'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 패딩 증가 (6,2→8,4)
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
                                ),
                                child: Text(
                                  '#${stop['stopId']}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 30, // 글자 크기 증가 (11→14)
                                    fontWeight: FontWeight.w500, // 글자 두께 약간 증가
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}