// widgets/map_widgets/stop_list_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'expandable_stop_list_item.dart'; // 확장 가능한 아이템 import

class StopListBottomSheet extends StatefulWidget {

  final List<dynamic> allStops;
  final String? selectedMarkerId;
  final Function(dynamic) onStopSelected;
  final Function() onRefresh;
  final bool isLoading;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) fetchArrivalInfo; // 도착 정보 가져오는 함수
  final Function(double) onHeightChanged; // 높이 변경 콜백

  const StopListBottomSheet({
    Key? key,
    required this.allStops,
    required this.selectedMarkerId,
    required this.onStopSelected,
    required this.onRefresh,
    required this.isLoading,
    required this.scaffoldKey,
    required this.fetchArrivalInfo,
    required this.onHeightChanged,
  }) : super(key: key);

  @override
  StopListBottomSheetState createState() =>StopListBottomSheetState();
}

class StopListBottomSheetState extends State<StopListBottomSheet> {
  PersistentBottomSheetController? _bottomSheetController;
  double _bottomSheetHeight = 300.0;
  final double _minSheetHeight = 100.0;
  double _maxSheetHeight= 500.0;
  bool _isDragging = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredStops = [];
  final ScrollController _scrollController = ScrollController();

  // 정류장 ID를 키로 사용하여 도착 정보를 저장하는 맵
  Map<String, List<dynamic>> _arrivalInfoMap = {};

  // 정류장별 로딩 상태 추적
  Map<String, bool> _loadingStates = {};



  void setSearchQuery(String query) {
    if (!mounted) return;

    _searchController.text = query;

    // 커서를 텍스트 맨 끝으로 보내기
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    // 필터 강제 수행
    final filtered = widget.allStops.where((stop) {
      final name = stop['nodeNm']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    if (mounted) {
      setState(() {
        _filteredStops = filtered;
      });
    }

    // 필터링 후 리스트가 비어있는지 확인
    if (_filteredStops.isEmpty && !query.isEmpty) {
      // 검색어가 정확히 일치하지 않을 경우 빈 필터를 방지
      setState(() {
        _filteredStops = widget.allStops;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _filteredStops = widget.allStops;

    // 초기화는 여전히 여기서 하고
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        _maxSheetHeight = screenHeight;
        _bottomSheetHeight = 300.0; // 초기 높이
      });

      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          showSheet();
          widget.onHeightChanged(_bottomSheetHeight);
        }
      });
    });
  }

  @override
  void didUpdateWidget(StopListBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allStops != oldWidget.allStops) {
      _filterStops(_searchController.text);
    }

    if (widget.selectedMarkerId != null &&
        widget.selectedMarkerId != oldWidget.selectedMarkerId) {
      _scrollToSelectedStop();
    }


  }
  void _scrollToSelectedStop() {
    final index = _filteredStops.indexWhere(
            (stop) => stop['nodeId'] == widget.selectedMarkerId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 82.0, // 리스트 아이템 대략적 높이
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void showSheet() {
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
      _bottomSheetController = null;
      return;
    }

    _bottomSheetController = widget.scaffoldKey.currentState?.showBottomSheet(
          (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: _bottomSheetHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // 드래그 핸들 + 헤더
                GestureDetector(
                  onVerticalDragStart: (_) {
                    setState(() => _isDragging = true);
                  },
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _bottomSheetHeight -= details.delta.dy;
                      if (_bottomSheetHeight < _minSheetHeight) {
                        _bottomSheetHeight = _minSheetHeight;
                      } else if (_bottomSheetHeight > _maxSheetHeight) {
                        _bottomSheetHeight = _maxSheetHeight;
                      }

                      // 높이 변경을 부모에게 알림
                      widget.onHeightChanged(_bottomSheetHeight);
                    });
                  },
                  onVerticalDragEnd: (_) {
                    setState(() => _isDragging = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        // 드래그 핸들
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.directions_bus, color: Colors.white, size: 22),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "전체 정류장 목록",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "${widget.allStops.length}개 정류장",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 검색 바
                Padding(
                  padding: EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '정류장 이름으로 검색',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterStops('');
                          setState(() {});
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      _filterStops(value);
                      setState(() {});
                    },
                  ),
                ),

                // 목록
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await widget.onRefresh();
                    },
                    child: widget.allStops.isEmpty
                        ? widget.isLoading
                        ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '정류장 정보를 가져오는 중...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ))
                        : ListView(
                      children: [
                        Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_off,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '정류장 정보가 없습니다.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '정류장 데이터를 불러올 수 없습니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => widget.onRefresh(),
                                icon: Icon(Icons.refresh),
                                label: Text('새로고침'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : _filteredStops.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '다른 검색어를 입력해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredStops.length,
                      itemBuilder: (context, index) {
                        // 인덱스 범위 확인 추가
                        if (index < 0 || index >= _filteredStops.length) {
                          return SizedBox(); // 유효하지 않은 인덱스일 경우 빈 위젯 반환
                        }

                        final stop = _filteredStops[index];
                        final String nodeId = stop['nodeId'] ?? '';
                        final bool isSelected = widget.selectedMarkerId == nodeId;

                        // 선택된 정류장이면 도착 정보 가져오기
                        if (isSelected && !_arrivalInfoMap.containsKey(nodeId)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _loadArrivalInfo(nodeId, setState);
                          });
                        }

                        return ExpandableStopListItem(
                          key: ValueKey(nodeId),
                          stop: stop,
                          isSelected: isSelected,
                          onTap: () {
                            widget.onStopSelected(stop);
                            if (!_arrivalInfoMap.containsKey(nodeId)) {
                              _loadArrivalInfo(nodeId, setState);
                            }
                            setState(() {});
                          },
                          arrivalInfo: _arrivalInfoMap[nodeId] ?? [],
                          isLoading: _loadingStates[nodeId] ?? false,
                          // 새로고침 콜백 추가
                          onRefresh: () {
                            _refreshStopArrivalInfo(nodeId, setState);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      enableDrag: false,
    );

    _bottomSheetController?.closed.then((value) {
      if (mounted) {
        // 바텀시트가 닫힐 때 높이를 0으로 설정
        widget.onHeightChanged(0);

        setState(() {
          _bottomSheetController = null;
        });
      }
    });
  }

  // 도착 정보 로딩 함수
  void _loadArrivalInfo(String nodeId, StateSetter bottomSheetSetState) {
    bottomSheetSetState(() {
      _loadingStates[nodeId] = true;
    });

    widget.fetchArrivalInfo(nodeId).then((arrivalInfo) {
      if (mounted) {
        setState(() {
          _arrivalInfoMap[nodeId] = arrivalInfo;
          _loadingStates[nodeId] = false;
        });

        // 바텀시트 상태 업데이트
        bottomSheetSetState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _arrivalInfoMap[nodeId] = [];
          _loadingStates[nodeId] = false;
        });

        // 바텀시트 상태 업데이트
        bottomSheetSetState(() {});
      }
    });
  }

  // 도착 정보 새로고침 함수 추가
  void _refreshStopArrivalInfo(String nodeId, StateSetter bottomSheetSetState) {
    // 로딩 상태로 설정
    bottomSheetSetState(() {
      _loadingStates[nodeId] = true;
    });

    // 도착 정보 다시 가져오기
    widget.fetchArrivalInfo(nodeId).then((arrivalInfo) {
      if (mounted) {
        setState(() {
          _arrivalInfoMap[nodeId] = arrivalInfo;
          _loadingStates[nodeId] = false;
        });

        // 바텀시트 상태 업데이트
        bottomSheetSetState(() {});

        // 성공 메시지 표시 (선택사항)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('도착 정보가 업데이트되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(10),
          ),
        );
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _loadingStates[nodeId] = false;
        });

        // 바텀시트 상태 업데이트
        bottomSheetSetState(() {});

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('도착 정보 업데이트에 실패했습니다.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(10),
          ),
        );
      }
    });
  }

  void _filterStops(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStops = widget.allStops;
      });
      return;
    }

    setState(() {
      _filteredStops = widget.allStops.where((stop) {
        final nodeNm = stop['nodeNm']?.toString().toLowerCase() ?? '';
        return nodeNm.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이 위젯은 빈 컨테이너를 반환하고 실제 UI는 바텀시트에서 처리됩니다.
    return Container();
  }

  @override
  void dispose() {
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
    }
    _searchController.dispose();
    super.dispose();
  }
}