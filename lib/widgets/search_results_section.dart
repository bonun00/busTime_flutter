import 'package:develoment/services/BusApiService.dart';
import 'package:flutter/material.dart';
import 'section_title.dart';
import 'route_map.dart';
import '../models/bus_favorite.dart';
import '../services/favorite_service.dart';
class SearchResultsSection extends StatefulWidget {
  final String currentRouteType;
  final String? selectedDeparture;
  final String? selectedArrival;
  final List<Map<String, dynamic>> schedules;
  final bool isLoading;
  final VoidCallback onClose;
  final BusApiService busApiService;

  const SearchResultsSection({
    Key? key,
    required this.currentRouteType,
    required this.selectedDeparture,
    required this.selectedArrival,
    required this.schedules,
    required this.isLoading,
    required this.onClose,
    required this.busApiService
  }) : super(key: key);

  @override
  _SearchResultsSectionState createState() => _SearchResultsSectionState();
}




class _SearchResultsSectionState extends State<SearchResultsSection> {
  // 필터링을 위한 상태 변수
  String _timeFilter = '전체';
  bool _showUpcomingOnly = false;
  // SearchResultsSection 위젯 내부에 상태 변수 추가
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.selectedDeparture != null && widget.selectedArrival != null) {
      final isFav = await _favoritesService.isFavorite(
          widget.selectedDeparture!,
          widget.selectedArrival!,
          widget.currentRouteType
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

// 즐겨찾기 토글 기능
  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        // 즐겨찾기 ID 찾기 및 삭제 로직
        final favorites = await _favoritesService.getFavorites();
        final favoriteList = favorites.where(
              (f) => f.departure == widget.selectedDeparture &&
              f.arrival == widget.selectedArrival &&
              f.routeType == widget.currentRouteType,
        ).toList();

        final BusFavorite? favorite = favoriteList.isNotEmpty ? favoriteList.first : null;

        if (favorite != null) {
          await _favoritesService.removeFavorite(favorite.id);
        }
      } else {
        await _favoritesService.addFavorite(
            widget.selectedDeparture!,
            widget.selectedArrival!,
            widget.currentRouteType
        );
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      // 사용자 피드백
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('오류가 발생했습니다: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }


// 시간표 항목 클릭 시 노선도 표시
  void _showRouteMapDialog(Map<String, dynamic> schedule) async {
    final busNumber = schedule['busNumber'];
    final arrivalTime = schedule['arrivalTime'];

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('노선 정보를 불러오는 중...'),
            ],
          ),
        ),
      ),
    );

    try {
      List<dynamic> routeData;

      // 현재 노선 타입에 따라 API 호출
      if (widget.currentRouteType == 'chilwon') {
        routeData = await widget.busApiService.fetchChilwonRoute(busNumber, arrivalTime);
      } else {
        routeData = await widget.busApiService.fetchMasanRoute(busNumber, arrivalTime);
      }

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (routeData.isNotEmpty) {
        // 노선도 표시 화면 열기
        _showFullScreenRouteMap(routeData, busNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('노선 정보를 불러올 수 없습니다.')),
        );
      }
    } catch (e) {
      // 에러 처리
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

// 전체 화면으로 노선도 표시
  void _showFullScreenRouteMap(List<dynamic> routeData, String busNumber) {
    final themeColor = widget.currentRouteType == 'chilwon'
        ? Color(0xFF388E3C)
        : Color(0xFF1976D2);

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text('버스 노선도'),
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: RouteMapWidget(
            routeData: routeData,
            busNumber: busNumber,
            selectedDeparture: widget.selectedDeparture,
            selectedArrival: widget.selectedArrival,
          ),
        ),
      ),
    );
  }
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
    final Color themeColor = widget.currentRouteType == 'chilwon'
        ? Color(0xFF388E3C)  // 진한 초록색
        : Color(0xFF1976D2);  // 진한 파란색

    final Color themeLightColor = widget.currentRouteType == 'chilwon'
        ? Color(0xFFE8F5E9)  // 연한 초록색
        : Color(0xFFE3F2FD);  // 연한 파란색

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeLightColor.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: themeColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '검색 결과',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // 즐겨찾기 버튼 추가
                    if (widget.selectedDeparture != null && widget.selectedArrival != null)
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.star : Icons.star_border,
                          color: _isFavorite ? Colors.amber : Colors.grey[600],
                          size: 22,
                        ),
                        onPressed: _toggleFavorite,
                        tooltip: '즐겨찾기',
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: widget.onClose,
                      icon: Icon(Icons.close, size: 18),
                      label: Text('닫기'),
                      style: TextButton.styleFrom(
                        foregroundColor: themeColor,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 필터 옵션들
          if (!widget.isLoading && widget.schedules.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '필터 옵션',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
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
                                  child: Text(
                                    timeRange,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _timeFilter == timeRange ? themeColor : Colors.black87,
                                    ),
                                  ),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _showUpcomingOnly = !_showUpcomingOnly;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 로딩
          if (widget.isLoading)
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '시간표 로딩 중...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildSchedulesCard(themeColor, themeLightColor),
        ],
      ),
    );
  }

  Widget _buildSchedulesCard(Color themeColor, Color themeLightColor) {
    final filteredSchedules = _filteredSchedules;

    if (widget.schedules.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '해당 구간의 버스 시간표가 없습니다.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredSchedules.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.filter_alt_off,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                '선택한 조건에 맞는 시간표가 없습니다.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _timeFilter = '전체';
                    _showUpcomingOnly = false;
                  });
                },
                icon: Icon(Icons.refresh, size: 16),
                label: Text('필터 초기화'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: themeColor,
                  elevation: 0,
                  textStyle: TextStyle(fontWeight: FontWeight.w500),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 현재 시간 정보
    final now = DateTime.now();
    final currentHourMin = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필터 적용됨 표시
          if (_timeFilter != '전체' || _showUpcomingOnly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeLightColor.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.filter_list,
                      size: 14,
                      color: themeColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '필터 적용됨: ${filteredSchedules.length}개 결과',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  if (_showUpcomingOnly) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: themeColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '현재 시간: $currentHourMin',
                            style: TextStyle(
                              fontSize: 11,
                              color: themeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // 테이블 헤더
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: themeLightColor.withOpacity(0.3),
              borderRadius: _timeFilter != '전체' || _showUpcomingOnly
                  ? BorderRadius.zero
                  : BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${widget.selectedDeparture ?? "?"} 출발',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${widget.selectedArrival ?? "?"} 도착',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '버스번호',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 시간표 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredSchedules.length,
            separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
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

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showRouteMapDialog(item);
                  },
                  child: Container(
                    color: isUpcoming ? themeLightColor.withOpacity(0.2) : null,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTimeColor(timeIndicator, themeColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  timeIndicator,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
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
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUpcoming ? themeColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              busNumber,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isUpcoming ? Colors.white : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 페이징 또는 더 보기 버튼 (선택적)
          if (filteredSchedules.length > 10)
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: TextButton.icon(
                onPressed: () {
                  // 더 보기 동작
                },
                icon: Icon(Icons.expand_more, size: 18),
                label: Text('더 보기'),
                style: TextButton.styleFrom(
                  foregroundColor: themeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 시간대별 색상 반환
  Color _getTimeColor(String timeIndicator, Color defaultColor) {
    switch (timeIndicator) {
      case '오전': return Colors.blue[600]!;
      case '오후': return Colors.amber[700]!;
      case '저녁': return Colors.purple[600]!;
      default: return defaultColor;
    }
  }
}