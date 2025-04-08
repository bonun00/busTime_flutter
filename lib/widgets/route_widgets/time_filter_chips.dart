import 'package:flutter/material.dart';

class TimeFilterChips extends StatelessWidget {
  final List<String> timeFilters;
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final Color themeColor;
  final bool showUpcomingOnly;
  final Function(bool) onUpcomingToggled;

  const TimeFilterChips({
    Key? key,
    required this.timeFilters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.themeColor,
    this.showUpcomingOnly = false,
    required this.onUpcomingToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 너비 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final chipWidth = (screenWidth - 40) / (timeFilters.length); // 페딩 증가로 인한 조정 (32→40)

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 패딩 증가 (16,8→20,12)
      child: Column(
        children: [
          // 시간대 필터 (균등 배치)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: timeFilters.map((filter) {
              bool isSelected = selectedFilter == filter;
              return SizedBox(
                width: chipWidth - 10, // 약간의 여유 공간 제공
                height: 48, // 높이 지정하여 더 큰 터치 영역 제공
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0), // 패딩 증가 (4.0→6.0)
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible, // 글자 잘림 방지
                      style: TextStyle(
                        fontSize: 18, // 글자 크기 추가
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: themeColor,
                  showCheckmark: false, // 체크 표시 제거
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 18, // 글자 크기 추가
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      onFilterSelected(filter);
                    }
                  },
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8), // 세로 패딩 추가 (0→8)
                  materialTapTargetSize: MaterialTapTargetSize.padded, // 탭 영역 크기 증가 (shrinkWrap→padded)
                  shape: RoundedRectangleBorder( // 모서리 둥글기 명시적 지정
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            }).toList(),
          ),

          // 현재 이후만 스위치 (2번째 행)
          SizedBox(height: 14), // 간격 증가 (8→14)
          GestureDetector(
            onTap: () {
              onUpcomingToggled(!showUpcomingOnly);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 패딩 증가 (8,12→12,16)
              decoration: BoxDecoration(
                color: showUpcomingOnly ? themeColor.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10), // 모서리 둥글기 증가 (8→10)
                border: Border.all(
                  color: showUpcomingOnly ? themeColor : Colors.grey[300]!,
                  width: 1.5, // 테두리 두께 증가 (1→1.5)
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showUpcomingOnly ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 24, // 아이콘 크기 증가 (18→24)
                    color: showUpcomingOnly ? themeColor : Colors.grey[600],
                  ),
                  SizedBox(width: 12), // 간격 증가 (8→12)
                  Text(
                    '현재 이후 시간표만 보기',
                    style: TextStyle(
                      fontSize: 18, // 글자 크기 증가 (14→18)
                      fontWeight: showUpcomingOnly ? FontWeight.bold : FontWeight.normal,
                      color: showUpcomingOnly ? themeColor : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}