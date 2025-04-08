import 'package:flutter/material.dart';

class BusSelectionChips extends StatelessWidget {
  final List<String> busNumbers;
  final Set<String> selectedBusNumbers;
  final Map<String, Color> busColors;
  final Function(String) onBusSelected;
  final Color themeColor;

  const BusSelectionChips({
    Key? key,
    required this.busNumbers,
    required this.selectedBusNumbers,
    required this.busColors,
    required this.onBusSelected,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // 높이 증가 (70→90)
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20), // 패딩 증가 (16→20)
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // 그림자 불투명도 증가 (0.05→0.08)
            blurRadius: 6, // 그림자 블러 효과 증가 (4→6)
            spreadRadius: 0,
            offset: Offset(0, 3), // 그림자 위치 증가 (2→3)
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24), // 모서리 둥글기 증가 (20→24)
          topRight: Radius.circular(24), // 모서리 둥글기 증가 (20→24)
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8), // 패딩 증가 (6→8)
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_bus, color: themeColor, size: 24), // 아이콘 크기 증가 (18→24)
          ),
          SizedBox(width: 12), // 간격 증가 (8→12)
          Text(
            "버스 선택:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 18, // 글자 크기 추가
            ),
          ),
          SizedBox(width: 20), // 간격 증가 (16→20)
          Expanded(
            child: Row(
              children: busNumbers.map((busNumber) {
                bool isSelected = selectedBusNumbers.contains(busNumber);
                return Padding(
                  padding: EdgeInsets.only(right: 12), // 패딩 증가 (8→12)
                  child: FilterChip(
                    label: Text('$busNumber번'),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: busColors[busNumber],
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 글자 크기 추가
                    ),
                    onSelected: (selected) {
                      onBusSelected(busNumber);
                    },
                    elevation: 0,
                    pressElevation: 3, // 누를 때 그림자 효과 증가 (2→3)
                    shadowColor: Colors.black26,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 패딩 증가 (12,8→16,10)
                    shape: RoundedRectangleBorder( // 모서리 둥글기 추가
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}