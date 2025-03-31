import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/bus_favorite.dart';
import '../services/BusApiService.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final BusApiService _busApiService = BusApiService();
  List<BusFavorite> _favorites = [];
  bool _isLoading = true;

  // 시간표 관련 상태 변수
  bool _isLoadingSchedule = false;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('즐겨찾기를 불러오는 중 오류가 발생했습니다.'),
      ));
    }
  }

  // 시간표 로딩 함수
  Future<void> _loadSchedule(BusFavorite favorite) async {
    setState(() {
      _isLoadingSchedule = true;
      _schedules = [];
    });

    try {
      List<dynamic> result = [];
      if (favorite.routeType == 'chilwon') {
        result = await _busApiService.fetchChilwonRouteSchedules(
          favorite.departure,
          favorite.arrival,
        );
      } else {
        result = await _busApiService.fetchMasanRouteSchedules(
          favorite.departure,
          favorite.arrival,
        );
      }

      // List<dynamic> -> List<Map<String, dynamic>>
      final schedules = result.map<Map<String, dynamic>>((e) =>
      Map<String, dynamic>.from(e)).toList();

      setState(() {
        _schedules = schedules;
        _isLoadingSchedule = false;
      });

      // 하단 시트 표시
      _showScheduleBottomSheet(favorite);

    } catch (e) {
      setState(() {
        _isLoadingSchedule = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('시간표를 불러오는 중 오류가 발생했습니다: $e'),
      ));
    }
  }

  // 하단 시트로 시간표 표시
  void _showScheduleBottomSheet(BusFavorite favorite) {
    final isChilwon = favorite.routeType == 'chilwon';
    final themeColor = isChilwon ? Color(0xFF388E3C) : Color(0xFF1976D2);
    final themeLightColor = isChilwon ? Color(0xFFE8F5E9) : Color(0xFFE3F2FD);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면의 90%까지 확장 가능
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // 초기 높이 (화면의 60%)
          minChildSize: 0.3, // 최소 높이 (화면의 30%)
          maxChildSize: 0.9, // 최대 높이 (화면의 90%)
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 드래그 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 헤더
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeLightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isChilwon ? Icons.directions_bus : Icons.directions_bus_filled,
                          color: themeColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${favorite.departure} → ${favorite.arrival}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${isChilwon ? '칠원' : '마산'} 노선 시간표',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  Divider(height: 24),

                  // 시간표 내용
                  Expanded(
                    child: _isLoadingSchedule
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          SizedBox(height: 16),
                          Text('시간표를 불러오는 중...'),
                        ],
                      ),
                    )
                        : _schedules.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_outlined,
                              size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            '해당 경로의 시간표가 없습니다',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      controller: scrollController,
                      itemCount: _schedules.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        final departureTime = schedule['departureTime'] ?? '--:--';
                        final arrivalTime = schedule['arrivalTime'] ?? '--:--';
                        final busNumber = schedule['busNumber'] ?? '-';

                        // 시간대 표시 (오전/오후/저녁)
                        String timeIndicator = '';
                        try {
                          int hour = int.parse(departureTime.split(':')[0]);
                          if (hour >= 5 && hour < 12) timeIndicator = '오전';
                          else if (hour >= 12 && hour < 18) timeIndicator = '오후';
                          else timeIndicator = '저녁';
                        } catch (e) {
                          timeIndicator = '';
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Text(
                                      departureTime,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
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
                                child: Text(arrivalTime),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    busNumber,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '즐겨찾기가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '검색 결과 화면에서 별표 아이콘을 눌러\n자주 이용하는 노선을 즐겨찾기에 추가하세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.separated(
        itemCount: _favorites.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          final isChilwon = favorite.routeType == 'chilwon';
          final themeColor = isChilwon
              ? Color(0xFF388E3C)
              : Color(0xFF1976D2);

          return Dismissible(
            key: Key(favorite.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await _favoritesService.removeFavorite(favorite.id);
              setState(() {
                _favorites.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('즐겨찾기에서 제거되었습니다'),
                duration: Duration(seconds: 2),
              ));
            },
            child: ListTile(
              onTap: () {
                // 시간표 로드 및 하단 시트 표시
                _loadSchedule(favorite);
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isChilwon ? Icons.directions_bus : Icons.directions_bus,
                  color: themeColor,
                ),
              ),
              title: Text(
                '${favorite.departure} → ${favorite.arrival}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${isChilwon ? '칠원' : '마산'} 노선${favorite.busNumber.isNotEmpty ? ' • 버스 ${favorite.busNumber}' : ''}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
            ),
          );
        },
      ),
    );
  }
}