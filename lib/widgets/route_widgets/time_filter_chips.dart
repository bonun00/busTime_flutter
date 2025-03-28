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
    final chipWidth = (screenWidth - 32) / (timeFilters.length); // 페딩 제외하고 균등하게 분배

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 시간대 필터 (균등 배치)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: timeFilters.map((filter) {
              bool isSelected = selectedFilter == filter;
              return SizedBox(
                width: chipWidth - 10, // 약간의 여유 공간 제공
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible, // 글자 잘림 방지
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: themeColor,
                  showCheckmark: false, // 체크 표시 제거
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      onFilterSelected(filter);
                    }
                  },
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }).toList(),
          ),

          // 현재 이후만 스위치 (2번째 행)
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              onUpcomingToggled(!showUpcomingOnly);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: showUpcomingOnly ? themeColor.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: showUpcomingOnly ? themeColor : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showUpcomingOnly ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: showUpcomingOnly ? themeColor : Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    '현재 이후 시간표만 보기',
                    style: TextStyle(
                      fontSize: 14,
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