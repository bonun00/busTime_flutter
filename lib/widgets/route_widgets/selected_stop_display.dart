import 'package:flutter/material.dart';

class SelectedStopDisplay extends StatelessWidget {
  final String stopName;
  final VoidCallback onClose;
  final Color themeColor;

  const SelectedStopDisplay({
    Key? key,
    required this.stopName,
    required this.onClose,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E9), // 연한 그린 배경색 (메인 테마에 맞게)
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: themeColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              stopName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: themeColor,
              size: 18,
            ),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}