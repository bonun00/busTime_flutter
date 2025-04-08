import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final Color color;

  const LoadingState({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50, // 로딩 인디케이터 크기 지정
            height: 50, // 로딩 인디케이터 크기 지정
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 4, // 선 두께 증가
            ),
          ),
          SizedBox(height: 24), // 간격 증가 (16→24)
          Text(
            "정보를 불러오는 중...",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 20, // 글자 크기 추가
            ),
          ),
        ],
      ),
    );
  }
}