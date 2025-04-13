import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // 그림자 효과 증가 (2→3)
      shadowColor: Colors.black26, // 그림자 불투명도 증가 (0.12→0.26)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 모서리 둥글기 증가 (10→12)
        side: BorderSide(color: Colors.grey[200]!, width: 1.5), // 테두리 추가
      ),
      child: Padding(
        padding: EdgeInsets.all(20), // 패딩 증가 (16→20)
        child: Column(
          children: [
            _buildInfoItem(
              icon: Icons.access_time,
              text: '버스 시간은 교통 상황에 따라 변동될 수 있습니다.',
            ),
            Divider(height: 24, thickness: 1.5), // 높이와 두께 증가 (16→24, 1→1.5)
            _buildInfoItem(
              icon: Icons.info,
              text: '이 버스 시간표는 함안군청에서 제공한 공식 데이터를 기반으로 작성되었습니다.',
            ),
            Divider(height: 24, thickness: 1.5), // 높이와 두께 증가 (16→24, 1→1.5)
            _buildInfoItem(
              icon: Icons.mail,
              text: '문의: 9bonun@gmail.com ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10), // 패딩 증가 (8→10)
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF388E3C), size: 22), // 아이콘 크기 증가 (16→22)
        ),
        SizedBox(width: 16), // 간격 증가 (12→16)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6), // 패딩 증가 (4→6)
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18, // 글자 크기 증가 (13→18)
                color: Colors.black87,
                height: 1.3, // 줄 간격 추가
              ),
            ),
          ),
        ),
      ],
    );
  }
}