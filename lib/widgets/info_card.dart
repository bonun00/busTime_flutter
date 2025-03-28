import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoItem(
              icon: Icons.access_time,
              text: '버스 시간은 교통 상황에 따라 변동될 수 있습니다.',
            ),
            Divider(height: 16),
            _buildInfoItem(
              icon: Icons.info,
              text: '이 버스 시간표는 함안군청에서 제공한 공식 데이터를 기반으로 작성되었습니다.',
            ),
            Divider(height: 16),
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF388E3C), size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}