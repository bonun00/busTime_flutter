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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$busNumber번',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '전체 노선도',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          margin: EdgeInsets.only(bottom: isLastStop ? 0 : 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 타임라인 부분
                Container(
                  width: 24,
                  child: Column(
                    children: [
                      // 정류장 점
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: stopColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: stopColor!.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)]
                              : null,
                        ),
                      ),
                      // 연결선
                      if (!isLastStop)
                        Expanded(
                          child: Container(
                            width: 2,
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
                    margin: EdgeInsets.only(left: 8, bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? stopColor!.withOpacity(0.1) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? stopColor! : Colors.grey[200]!,
                        width: isSelected ? 1.5 : 1,
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
                                  fontSize: isSelected ? 16 : 15,
                                  color: isSelected ? stopColor : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stopColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isSelectedDeparture ? '출발' : '도착',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '도착시간: $arrivalTime',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            // 정류장 번호가 있다면 표시
                            if (stop['stopId'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${stop['stopId']}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 11,
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
