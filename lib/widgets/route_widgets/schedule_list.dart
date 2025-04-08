import 'package:flutter/material.dart';

class ScheduleList extends StatelessWidget {
  final Map<String, List<dynamic>> busSchedules; // 버스 번호별 원본 시간표 데이터
  final List<Map<String, dynamic>> schedules;
  final String? expandedTimeId;
  final Map<String, Color> busColors;
  final Map<String, List<dynamic>> busRoutes;
  final String? selectedStop;
  final Color defaultColor;
  final Function(String, String, String) onTapSchedule;
  final String Function(String) formatTime;
  final Future<void> Function() onRefresh;
  final bool showUpcomingOnly;

  const ScheduleList({
    Key? key,
    required this.busSchedules,
    required this.schedules,
    required this.expandedTimeId,
    required this.busColors,
    required this.busRoutes,
    required this.selectedStop,
    required this.defaultColor,
    required this.onTapSchedule,
    required this.formatTime,
    required this.onRefresh,
    this.showUpcomingOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: defaultColor,
      displacement: 60, // 당겨서 새로고침 시 더 많이 당겨야 하도록 조정
      strokeWidth: 3.0, // 로딩 인디케이터 두께 증가
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 30), // 여백 증가 (16,8,16,24 → 20,12,20,30)
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          var bus = schedules[index];
          String displayBusNumber = bus['busNumber']; // 표시용 버스 번호
          String apiOriginalBusNumber = bus['originalBusNumber'] ?? displayBusNumber; // API에서 받은 원본 버스 번호
          String destination = bus['routeName'] ?? ''; // API에서 받은 종점 정보

          String timeId = '${displayBusNumber}_${bus['arrivalTime']}';
          String time = formatTime(bus['arrivalTime']);
          bool isExpanded = expandedTimeId == timeId;
          Color busColor = busColors[displayBusNumber] ?? defaultColor;

          // 현재 시간 이후인지 확인
          bool isUpcoming = false;
          try {
            List<String> parts = time.split(':');
            int hour = int.parse(parts[0]);
            int minute = int.parse(parts[1]);
            isUpcoming = (hour > now.hour) || (hour == now.hour && minute >= now.minute);
          } catch (e) {
            // 시간 형식이 잘못된 경우 에러 무시
          }

          // 현재 시간 이후 강조 표시
          final bool shouldHighlight = showUpcomingOnly && isUpcoming;

          return Column(
            children: [
              // 시간표 항목
              Container(
                margin: EdgeInsets.only(bottom: isExpanded ? 0 : 12), // 마진 증가 (8→12)
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14), // 모서리 둥글기 증가 (12→14)
                    bottom: Radius.circular(isExpanded ? 0 : 14), // 모서리 둥글기 증가 (12→14)
                  ),
                  elevation: 1, // 약간의 그림자 추가 (0→1)
                  child: InkWell(
                    onTap: () {
                      // API에서 받은 원본 버스 번호를 그대로 전달
                      onTapSchedule(timeId, time, apiOriginalBusNumber);
                      print('버스 번호 전달: $apiOriginalBusNumber');
                    },
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14), // 모서리 둥글기 증가 (12→14)
                      bottom: Radius.circular(isExpanded ? 0 : 14), // 모서리 둥글기 증가 (12→14)
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20, // 패딩 증가 (16→20)
                        vertical: 16, // 패딩 증가 (12→16)
                      ),
                      decoration: BoxDecoration(
                        color: shouldHighlight ? busColor.withOpacity(0.05) : null,
                        border: Border.all(
                          color: isExpanded
                              ? busColor
                              : Colors.grey[300]!,
                          width: 1.5, // 테두리 두께 증가 (1→1.5)
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14), // 모서리 둥글기 증가 (12→14)
                          bottom: Radius.circular(isExpanded ? 0 : 14), // 모서리 둥글기 증가 (12→14)
                        ),
                      ),
                      child: Row(
                        children: [
                          // 버스 번호
                          Container(
                            width: 60, // 크기 증가 (50→60)
                            height: 60, // 크기 증가 (50→60)
                            decoration: BoxDecoration(
                              color: busColor,
                              borderRadius: BorderRadius.circular(10), // 모서리 둥글기 증가 (8→10)
                              boxShadow: [
                                BoxShadow(
                                  color: busColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              displayBusNumber, // 화면에는 간단한 버스 번호 표시 (예: 113)
                              style: TextStyle(
                                fontSize: 22, // 글자 크기 증가 (18→22)
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 20), // 간격 증가 (16→20)
                          // 시간 및 상세 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 24, // 글자 크기 증가 (20→24)
                                        fontWeight: shouldHighlight ? FontWeight.bold : FontWeight.normal,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (isUpcoming && showUpcomingOnly) ...[
                                      SizedBox(width: 8), // 간격 증가 (6→8)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 패딩 증가 (6,2→8,4)
                                        decoration: BoxDecoration(
                                          color: busColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 14, // 아이콘 크기 증가 (10→14)
                                              color: busColor,
                                            ),
                                            SizedBox(width: 4), // 간격 증가 (2→4)
                                            Text(
                                              '예정',
                                              style: TextStyle(
                                                fontSize: 14, // 글자 크기 증가 (10→14)
                                                fontWeight: FontWeight.bold,
                                                color: busColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 8), // 간격 증가 (4→8)
                                // 현재 정류장 정보
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 18, // 아이콘 크기 증가 (14→18)
                                      color: busColor,
                                    ),
                                    SizedBox(width: 6), // 간격 증가 (4→6)
                                    Expanded(
                                      child: Text(
                                        selectedStop ?? "",
                                        style: TextStyle(
                                          fontSize: 16, // 글자 크기 증가 (12→16)
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                // 종점 정보 표시 (API에서 받아온 경우)
                                if (destination.isNotEmpty) ...[
                                  SizedBox(height: 8), // 간격 증가 (4→8)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        size: 18, // 아이콘 크기 증가 (14→18)
                                        color: busColor,
                                      ),
                                      SizedBox(width: 6), // 간격 증가 (4→6)
                                      Expanded(
                                        child: Text(
                                          "종점: $destination",
                                          style: TextStyle(
                                            fontSize: 16, // 글자 크기 증가 (12→16)
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                // 원본 버스 번호도 표시 (디버깅 용도)
                                if (apiOriginalBusNumber != displayBusNumber) ...[
                                  SizedBox(height: 8), // 간격 증가 (4→8)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.numbers,
                                        size: 18, // 아이콘 크기 증가 (14→18)
                                        color: busColor,
                                      ),
                                      SizedBox(width: 6), // 간격 증가 (4→6)
                                      Text(
                                        apiOriginalBusNumber,
                                        style: TextStyle(
                                          fontSize: 16, // 글자 크기 증가 (12→16)
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // 확장 아이콘
                          Container(
                            width: 36, // 크기 증가 (28→36)
                            height: 36, // 크기 증가 (28→36)
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? busColor
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: isExpanded ? Colors.white : Colors.grey[600],
                              size: 24, // 아이콘 크기 증가 (18→24)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 노선 정보 (확장 시)
              if (isExpanded && busRoutes.containsKey(timeId))
                _buildRouteInfo(context, busColor, busRoutes[timeId]!, selectedStop),
            ],
          );
        },
      ),
    );
  }

// _buildRouteInfo 함수 수정 부분:
  Widget _buildRouteInfo(BuildContext context, Color busColor, List<dynamic> routes, String? selectedStop) {
    final now = DateTime.now();

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 12), // 마진 증가 (8→12)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(14), // 모서리 둥글기 증가 (12→14)
        ),
        border: Border.all(
          color: busColor,
          width: 1.5, // 테두리 두께 증가 (1→1.5)
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 패딩 증가 (16,8→20,12)
            decoration: BoxDecoration(
              color: busColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: busColor.withOpacity(0.2),
                  width: 1.5, // 테두리 두께 증가 (1→1.5)
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 20, // 아이콘 크기 증가 (16→20)
                  color: busColor,
                ),
                SizedBox(width: 10), // 간격 증가 (8→10)
                Text(
                  '노선 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: busColor,
                    fontSize: 18, // 글자 크기 증가 (14→18)
                  ),
                ),
                if (showUpcomingOnly) ...[
                  Spacer(),
                  Text(
                    '현재 시간: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16, // 글자 크기 증가 (12→16)
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 노선 목록 - ListView를 Column으로 변경
          Column(
            children: List.generate(routes.length, (index) {
              var stop = routes[index];
              String stopName = stop['stopName'] ?? '';
              String stopTime = formatTime(stop['arrivalTime'] ?? '');
              bool isCurrentStop = stopName == selectedStop;
              bool isLastStop = index == routes.length - 1; // 마지막 정류장(종점) 여부

              // 현재 시간 이후인지 확인
              bool isUpcoming = false;
              try {
                List<String> parts = stopTime.split(':');
                int hour = int.parse(parts[0]);
                int minute = int.parse(parts[1]);
                isUpcoming = (hour > now.hour) || (hour == now.hour && minute >= now.minute);
              } catch (e) {
                // 시간 형식이 잘못된 경우 에러 무시
              }

              return Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16), // 패딩 증가 (16,12,16,12→20,16,20,16)
                decoration: BoxDecoration(
                  color: isCurrentStop
                      ? busColor.withOpacity(0.1)
                      : (isLastStop)
                      ? busColor.withOpacity(0.08) // 종점 배경색 변경
                      : (showUpcomingOnly && isUpcoming)
                      ? busColor.withOpacity(0.05)
                      : null,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1.5, // 테두리 두께 증가 (1→1.5)
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 정류장 순서
                    Container(
                      width: 30, // 크기 증가 (24→30)
                      height: 30, // 크기 증가 (24→30)
                      decoration: BoxDecoration(
                        color: isCurrentStop
                            ? busColor
                            : isLastStop
                            ? Color(0xFF8E24AA) // 종점은 보라색으로 표시
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isLastStop
                          ? Icon(Icons.flag, size: 18, color: Colors.white) // 아이콘 크기 증가 (14→18)
                          : Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // 글자 크기 증가 (12→16)
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // 간격 증가 (16→20)
                    // 정류장 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stopName,
                                  style: TextStyle(
                                    fontSize: 18, // 글자 크기 증가 (14→18)
                                    fontWeight: isCurrentStop || isLastStop || (showUpcomingOnly && isUpcoming)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrentStop
                                        ? busColor
                                        : isLastStop
                                        ? Color(0xFF8E24AA) // 종점 텍스트 색상
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isLastStop)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10, // 패딩 증가 (8→10)
                                    vertical: 4, // 패딩 증가 (2→4)
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF8E24AA).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '종점',
                                    style: TextStyle(
                                      color: Color(0xFF8E24AA),
                                      fontSize: 14, // 글자 크기 증가 (10→14)
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8), // 간격 증가 (4→8)
                          Row(
                            children: [
                              Text(
                                "도착 시간: $stopTime",
                                style: TextStyle(
                                  fontSize: 16, // 글자 크기 증가 (12→16)
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (showUpcomingOnly && isUpcoming) ...[
                                SizedBox(width: 6), // 간격 증가 (4→6)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), // 패딩 증가 (4,1→6,2)
                                  decoration: BoxDecoration(
                                    color: busColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
                                  ),
                                  child: Text(
                                    '예정',
                                    style: TextStyle(
                                      fontSize: 12, // 글자 크기 증가 (9→12)
                                      color: busColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 현재 정류장 표시
                    if (isCurrentStop)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10, // 패딩 증가 (8→10)
                          vertical: 6, // 패딩 증가 (4→6)
                        ),
                        decoration: BoxDecoration(
                          color: busColor,
                          borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
                        ),
                        child: Text(
                          '현재',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // 글자 크기 증가 (10→14)
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}