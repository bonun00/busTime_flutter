import 'package:flutter/material.dart';

class StopList extends StatelessWidget {
  final List<String> stops;
  final Function(String) onStopSelected;
  final Color themeColor;

  const StopList({
    Key? key,
    required this.stops,
    required this.onStopSelected,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 패딩 증가 (16,8→20,12)
      itemCount: stops.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1, // 약간의 그림자 추가 (0→1)
          margin: EdgeInsets.only(bottom: 12), // 마진 증가 (8→12)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
            side: BorderSide(color: Colors.grey[300]!, width: 1.5), // 테두리 두께 증가 (1→1.5)
          ),
          child: InkWell(
            onTap: () => onStopSelected(stops[index]),
            borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
            child: Padding(
              padding: EdgeInsets.all(20), // 패딩 증가 (16→20)
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12), // 패딩 증가 (10→12)
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9), // 연한 그린 배경색
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: themeColor,
                      size: 24, // 아이콘 크기 지정 (기본→24)
                    ),
                  ),
                  SizedBox(width: 20), // 간격 증가 (16→20)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stops[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // 글자 크기 증가 (16→20)
                          ),
                        ),
                        SizedBox(height: 8), // 간격 증가 (4→8)
                        Text(
                          '선택하여 시간표 보기',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16, // 글자 크기 증가 (12→16)
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: themeColor,
                    size: 20, // 아이콘 크기 증가 (16→20)
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}