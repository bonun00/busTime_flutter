import 'package:flutter/material.dart';

class LiveTracking extends StatelessWidget {
  final bool usePrimaryTheme;

  const LiveTracking({
    Key? key,
    this.usePrimaryTheme = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 메인 페이지 테마 색상
    final primaryColor = Color(0xFF388E3C); // 초록색
    final secondaryColor = Color(0xFF1976D2); // 파란색

    // 선택된 테마 색상
    final themeColor = usePrimaryTheme ? primaryColor : secondaryColor;

    return Card(
      elevation: 3, // 그림자 효과 증가 (2→3)
      shadowColor: Colors.black26, // 그림자 불투명도 증가 (0.12→0.26)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
        side: BorderSide(color: Colors.grey[200]!, width: 1.5), // 테두리 두께 증가 (1→1.5)
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/KakaoMapScreen'),
        borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
          ),
          child: Padding(
            padding: EdgeInsets.all(20), // 패딩 증가 (16→20)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10), // 패딩 증가 (8→10)
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글기 증가 (8→10)
                      ),
                      child: Icon(Icons.my_location,
                          color: themeColor, size: 24), // 아이콘 크기 증가 (18→24)
                    ),
                    SizedBox(width: 16), // 간격 증가 (12→16)
                    Expanded(
                      child: Text(
                        '실시간 버스 위치',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22, // 글자 크기 증가 (16→22)
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 패딩 증가 (6,2→8,4)
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, // 크기 증가 (6→8)
                            height: 8, // 크기 증가 (6→8)
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6), // 간격 증가 (4→6)
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14, // 글자 크기 증가 (10→14)
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // 간격 증가 (12→16)
                Text(
                  '현재 운행 중인 버스의 위치를 지도에서 확인할 수 있습니다.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16, // 글자 크기 증가 (12→16)
                  ),
                ),
                SizedBox(height: 20), // 간격 증가 (16→20)
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 패딩 증가 (12,6→16,10)
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(24), // 모서리 둥글기 증가 (20→24)
                        ),
                        child: Row(
                          children: [
                            Text(
                                '지도 보기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16, // 글자 크기 증가 (12→16)
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            SizedBox(width: 6), // 간격 증가 (4→6)
                            Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16 // 아이콘 크기 증가 (12→16)
                            ),
                          ],
                        ),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}