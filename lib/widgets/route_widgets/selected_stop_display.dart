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
      margin: EdgeInsets.fromLTRB(20, 12, 20, 0), // 마진 증가 (16,8,16,0→20,12,20,0)
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14), // 패딩 증가 (16,10→20,14)
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E9), // 연한 그린 배경색 (메인 테마에 맞게)
        borderRadius: BorderRadius.circular(10), // 모서리 둥글기 증가 (8→10)
        border: Border.all(
          color: themeColor.withOpacity(0.3),
          width: 1.5, // 테두리 두께 증가 (1→1.5)
        ),
        boxShadow: [ // 그림자 효과 추가
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: themeColor,
            size: 26, // 아이콘 크기 증가 (20→26)
          ),
          SizedBox(width: 12), // 간격 증가 (8→12)
          Expanded(
            child: Text(
              stopName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 18, // 글자 크기 추가
              ),
            ),
          ),
          SizedBox(width: 8), // 간격 추가
          // 닫기 버튼을 더 눌러지기 쉽게 수정
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(8), // 패딩 증가로 더 큰 터치 영역
              child: Icon(
                Icons.close,
                color: themeColor,
                size: 24, // 아이콘 크기 증가 (18→24)
              ),
            ),
          ),
        ],
      ),
    );
  }
}