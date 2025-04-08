import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30, // 높이 더 증가 (24→30)
          width: 6,   // 너비 더 증가 (4→6)
          decoration: BoxDecoration(
            color: Color(0xFF388E3C),
            borderRadius: BorderRadius.circular(3), // 모서리 둥글기 증가 (2→3)
          ),
        ),
        SizedBox(width: 14), // 간격 더 증가 (12→14)
        Text(
          title,
          style: TextStyle(
            fontSize: 24, // 글자 크기 더 증가 (20→24)
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}