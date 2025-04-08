import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color iconColor;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 100, // 아이콘 크기 증가 (80→100)
            color: iconColor.withOpacity(0.5),
          ),
          SizedBox(height: 24), // 간격 증가 (16→24)
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 24, // 글자 크기 증가 (18→24)
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // 중앙 정렬 추가
          ),
          SizedBox(height: 12), // 간격 증가 (8→12)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24), // 패딩 추가
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 18, // 글자 크기 증가 (14→18)
              ),
              textAlign: TextAlign.center, // 중앙 정렬 추가
            ),
          ),
          SizedBox(height: 32), // 간격 증가 (24→32)
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 패딩 증가 (24,12→32,16)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (8→12)
              ),
              elevation: 3, // 그림자 효과 추가
              textStyle: TextStyle(
                fontSize: 18, // 버튼 텍스트 크기 증가
                fontWeight: FontWeight.bold, // 글자 두께 증가
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}