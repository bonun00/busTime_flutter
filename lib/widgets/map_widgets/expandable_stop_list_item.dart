// 확장 가능한 정류장 리스트 아이템
// 이 위젯은 StopListBottomSheet 내에서 사용됩니다.

import 'package:flutter/material.dart';

class ExpandableStopListItem extends StatefulWidget {
  final dynamic stop;
  final bool isSelected;
  final Function() onTap;
  final List<dynamic> arrivalInfo;
  final bool isLoading;
  final Function()? onRefresh; // 새로고침 콜백 추가

  const ExpandableStopListItem({
    Key? key,
    required this.stop,
    required this.isSelected,
    required this.onTap,
    required this.arrivalInfo,
    this.isLoading = false,
    this.onRefresh, // 선택적 파라미터
  }) : super(key: key);

  @override
  _ExpandableStopListItemState createState() => _ExpandableStopListItemState();
}

class _ExpandableStopListItemState extends State<ExpandableStopListItem> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(ExpandableStopListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 항목이 선택되면 자동으로 확장
    if (widget.isSelected && !oldWidget.isSelected) {
      setState(() {
        _isExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isSelected ? Colors.blue.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
        border: Border.all(
          color: widget.isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
          width: widget.isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            widget.onTap();
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // 정류장 기본 정보
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 정류장 아이콘
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions_bus,
                          color: widget.isSelected ? Colors.white : Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // 정류장 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stop['nodeNm'] ?? '알 수 없는 정류장',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                              color: widget.isSelected ? Colors.blue[800] : Colors.black87,
                            ),
                          ),
                          // SizedBox(height: 4),
                        ],
                      ),
                    ),

                    // 확장/축소 아이콘
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: widget.isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: widget.isSelected ? Colors.blue : Colors.grey[400],
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // 확장된 경우 도착 정보 표시
              if (_isExpanded) ...[
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                widget.isLoading
                    ? Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
                    : widget.arrivalInfo.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 36,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '도착 예정 버스가 없습니다',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (widget.onRefresh != null) ...[
                          SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: widget.onRefresh,
                            icon: Icon(Icons.refresh, size: 16, color: Colors.blue),
                            label: Text(
                              '새로고침',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.05),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 12, right: 16),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            '버스 도착 정보',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),

                          SizedBox(width: 8),
                          Text(
                            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} 기준',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(12),
                      itemCount: widget.arrivalInfo.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final info = widget.arrivalInfo[index];

                        // 버스 정보 추출
                        final routeNo = info['routeNo'] ?? '알 수 없음';
                        final routeTp = info['routeTp'] ?? '일반버스';
                        final int arrTime = info['arrTime'] ?? 0;
                        final int arrPrevStationCnt = info['arrPrevStationCnt'] ?? 0;

                        // 도착 시간에 따른 색상 설정
                        Color busColor;
                        String arrTimeText;

                        if (arrTime <= 3) {
                          busColor = Colors.red;
                          arrTimeText = '곧 도착';
                        } else if (arrTime <= 10) {
                          busColor = Colors.orange;
                          arrTimeText = '$arrTime분 후';
                        } else {
                          busColor = Colors.blue;
                          arrTimeText = '$arrTime분 후';
                        }

                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // 버스 번호
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: busColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  routeNo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // 버스 유형
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      routeTp,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '남은 정류장: $arrPrevStationCnt개',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 도착 시간
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: busColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: busColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  arrTimeText,
                                  style: TextStyle(
                                    color: busColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // 정보 목록 아래에 새로고침 버튼 추가 (모바일에서 더 접근성 좋음)
                    if (widget.onRefresh != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: widget.onRefresh,
                            icon: Icon(Icons.refresh, color: Colors.blue),
                            label: Text('도착 정보 새로고침'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.05),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}