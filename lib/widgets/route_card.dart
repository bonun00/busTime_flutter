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
      elevation: 2,
      shadowColor: themeColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeColor.withOpacity(0.05), width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘 컨테이너
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: themeColor.withOpacity(0.05)),
                ),
                child: Icon(icon, color: themeColor, size: 24),
              ),
              SizedBox(width: 14),
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // 화살표 아이콘
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios, color: themeColor, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}