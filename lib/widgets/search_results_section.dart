import 'package:flutter/material.dart';
import 'section_title.dart';

class SearchResultsSection extends StatefulWidget {
  final String currentRouteType;
  final String? selectedDeparture;
  final String? selectedArrival;
  final List<Map<String, dynamic>> schedules;
  final bool isLoading;
  final VoidCallback onClose;

  const SearchResultsSection({
    Key? key,
    required this.currentRouteType,
    required this.selectedDeparture,
    required this.selectedArrival,
    required this.schedules,
    required this.isLoading,
    required this.onClose,
  }) : super(key: key);

  @override
  _SearchResultsSectionState createState() => _SearchResultsSectionState();
}

class _SearchResultsSectionState extends State<SearchResultsSection> {
  // 필터링을 위한 상태 변수
  String _timeFilter = '전체';
  bool _showUpcomingOnly = false;

  // 시간대별 필터링
  List<Map<String, dynamic>> get _filteredSchedules {
    List<Map<String, dynamic>> result = List.from(widget.schedules);

    // 시간대로 필터링
    if (_timeFilter != '전체') {
      result = result.where((schedule) {
        String time = schedule['departureTime'] ?? '';
        if (time.isEmpty) return false;

        try {
          int hour = int.parse(time.split(':')[0]);
          if (_timeFilter == '오전') return hour >= 5 && hour < 12;
          if (_timeFilter == '오후') return hour >= 12 && hour < 18;
          if (_timeFilter == '저녁') return hour >= 18 || hour < 5;
        } catch (e) {
          return false;
        }

        return true;
      }).toList();
    }

    // 현재 시간 이후만 표시
    if (_showUpcomingOnly) {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      result = result.where((schedule) {
        String time = schedule['departureTime'] ?? '';
        if (time.isEmpty) return false;

        try {
          final parts = time.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);

          // 현재 시간과 비교
          return (hour > currentHour) || (hour == currentHour && minute >= currentMinute);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // 테마 색상
    final Color themeColor = (widget.currentRouteType == 'chilwon')
        ? Color(0xFF388E3C)
        : Color(0xFF1976D2);
    final Color themeLightColor = (widget.currentRouteType == 'chilwon')
        ? Color(0xFFE8F5E9)
        : Color(0xFFE3F2FD);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionTitle(title: '검색 결과'),
            TextButton(
              onPressed: widget.onClose,
              child: Text(
                '닫기',
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // 검색 정보 표시
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: themeLightColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: themeColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.selectedDeparture ?? "?"} → ${widget.selectedArrival ?? "?"} 노선 시간표',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // 필터 옵션들
        if (!widget.isLoading && widget.schedules.isNotEmpty) ...[
          Row(
            children: [
              // 시간대 필터
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _timeFilter,
                      hint: Text('시간대', style: TextStyle(fontSize: 13)),
                      isExpanded: true,
                      isDense: true,
                      icon: Icon(Icons.access_time, size: 18, color: themeColor),
                      items: ['전체', '오전', '오후', '저녁'].map((timeRange) {
                        return DropdownMenuItem<String>(
                          value: timeRange,
                          child: Text(timeRange),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _timeFilter = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // 현재 시간 이후만 표시 체크박스
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showUpcomingOnly = !_showUpcomingOnly;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _showUpcomingOnly ? themeColor : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _showUpcomingOnly ? themeLightColor : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showUpcomingOnly
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color: _showUpcomingOnly ? themeColor : Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '현재 이후 시간표만',
                            style: TextStyle(
                              fontSize: 13,
                              color: _showUpcomingOnly ? themeColor : Colors.grey[800],
                              fontWeight: _showUpcomingOnly ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],

        // 로딩
        if (widget.isLoading)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          )
        else
          _buildSchedulesCard(themeColor, themeLightColor),
      ],
    );
  }

  Widget _buildSchedulesCard(Color themeColor, Color themeLightColor) {
    final filteredSchedules = _filteredSchedules;

    if (widget.schedules.isEmpty) {
      return Center(
        child: Text(
          '해당 구간의 버스 시간표가 없습니다.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    if (filteredSchedules.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              '선택한 조건에 맞는 시간표가 없습니다.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _timeFilter = '전체';
                  _showUpcomingOnly = false;
                });
              },
              icon: Icon(Icons.refresh, size: 16),
              label: Text('필터 초기화'),
              style: TextButton.styleFrom(
                foregroundColor: themeColor,
              ),
            ),
          ],
        ),
      );
    }

    // 현재 시간 정보
    final now = DateTime.now();
    final currentHourMin = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 필터 적용됨 표시
            if (_timeFilter != '전체' || _showUpcomingOnly)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 14,
                      color: themeColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '필터 적용됨: ${filteredSchedules.length}개 결과',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Spacer(),
                    if (_showUpcomingOnly) ...[
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: themeColor,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '현재 시간: $currentHourMin',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // 테이블 헤더
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '출발',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '도착',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '버스번호',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),

            // 시간표 리스트
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredSchedules.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final item = filteredSchedules[index];
                final departureTime = item['departureTime'] ?? '--:--';
                final arrivalTime   = item['arrivalTime']   ?? '--:--';
                final busNumber     = item['busNumber']     ?? '-';

                // 시간대 표시 (AM/PM)
                String timeIndicator = '';
                bool isUpcoming = false;
                try {
                  // 시간대 계산
                  int hour = int.parse(departureTime.split(':')[0]);
                  if (hour >= 5 && hour < 12) timeIndicator = '오전';
                  else if (hour >= 12 && hour < 18) timeIndicator = '오후';
                  else timeIndicator = '저녁';

                  // 현재 시간과 비교
                  if (_showUpcomingOnly) {
                    int minute = int.parse(departureTime.split(':')[1]);
                    isUpcoming = (hour > now.hour) ||
                        (hour == now.hour && minute >= now.minute);
                  }
                } catch (e) {}

                return Container(
                  color: isUpcoming ? themeLightColor.withOpacity(0.3) : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Text(
                                departureTime,
                                style: TextStyle(
                                  fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  timeIndicator,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            arrivalTime,
                            style: TextStyle(
                              fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUpcoming ? themeColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              busNumber,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isUpcoming ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}