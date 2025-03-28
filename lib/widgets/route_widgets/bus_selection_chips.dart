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
      height: 70,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_bus, color: themeColor, size: 18),
          ),
          SizedBox(width: 8),
          Text(
            "버스 선택:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              children: busNumbers.map((busNumber) {
                bool isSelected = selectedBusNumbers.contains(busNumber);
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('$busNumber번'),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: busColors[busNumber],
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      onBusSelected(busNumber);
                    },
                    elevation: 0,
                    pressElevation: 2,
                    shadowColor: Colors.black26,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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