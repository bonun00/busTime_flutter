import 'package:flutter/material.dart';

class StopSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;

  const StopSearchField({
    Key? key,
    required this.controller,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // 마진 증가 (16,16,16,0→20,20,20,0)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
        border: Border.all(
          color: themeColor.withOpacity(0.2),
          width: 1.5, // 테두리 두께 증가 (1→1.5)
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.08), // 그림자 불투명도 증가 (0.05→0.08)
            blurRadius: 12, // 블러 효과 증가 (10→12)
            spreadRadius: 1, // 퍼짐 효과 추가 (0→1)
            offset: Offset(0, 3), // 그림자 위치 조정 (0,2→0,3)
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 8), // 간격 증가 (4→8)
          Container(
            padding: EdgeInsets.all(10), // 패딩 증가 (8→10)
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: themeColor, size: 24), // 아이콘 크기 증가 (18→24)
          ),
          SizedBox(width: 10), // 간격 증가 (6→10)
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '정류장 검색',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18, // 힌트 텍스트 크기 증가 (15→18)
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: themeColor, size: 24), // 아이콘 크기 증가 (18→24)
                      onPressed: () {
                        controller.clear();
                      },
                      padding: EdgeInsets.all(8), // 패딩 추가로 터치 영역 증가
                      constraints: BoxConstraints(
                        minWidth: 48, // 최소 너비 지정
                        minHeight: 48, // 최소 높이 지정
                      ),
                    )
                        : SizedBox.shrink();
                  },
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18), // 패딩 증가 (15→18)
              ),
              style: TextStyle(
                fontSize: 18, // 텍스트 크기 증가 (15→18)
                color: Colors.black87,
              ),
              cursorColor: themeColor,
              cursorWidth: 2.0, // 커서 너비 증가 (기본→2.0)
            ),
          ),
        ],
      ),
    );
  }
}