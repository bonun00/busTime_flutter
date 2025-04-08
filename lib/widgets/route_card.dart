import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String routeName;

  const RouteCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 테마 색상: 초록색(0xFF388E3C)과 파란색(0xFF1976D2) 사용
    final Color themeColor = color;

    return Card(
      elevation: 3, // 그림자 효과 증가 (2→3)
      shadowColor: themeColor.withOpacity(0.2), // 그림자 불투명도 증가 (0.1→0.2)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
        side: BorderSide(color: themeColor.withOpacity(0.1), width: 1.5), // 테두리 두께 증가 (1→1.5)
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        borderRadius: BorderRadius.circular(14), // 모서리 둥글기 증가 (12→14)
        child: Padding(
          padding: EdgeInsets.all(20), // 패딩 증가 (16→20)
          child: Row(
            children: [
              // 아이콘 컨테이너
              Container(
                width: 60, // 컨테이너 크기 증가 (48→60)
                height: 60, // 컨테이너 크기 증가 (48→60)
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
                  border: Border.all(color: themeColor.withOpacity(0.1), width: 1.5), // 테두리 두께 증가
                ),
                child: Icon(icon, color: themeColor, size: 30), // 아이콘 크기 증가 (24→30)
              ),
              SizedBox(width: 16), // 간격 증가 (14→16)
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20, // 글자 크기 증가 (15→20)
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6), // 간격 증가 (3→6)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16, // 글자 크기 증가 (13→16)
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // 화살표 아이콘
              Container(
                padding: EdgeInsets.all(10), // 패딩 증가 (6→10)
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1), // 불투명도 증가 (0.05→0.1)
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios, color: themeColor, size: 18), // 아이콘 크기 증가 (14→18)
              ),
            ],
          ),
        ),
      ),
    );
  }
}