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
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 4),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: themeColor, size: 18),
          ),
          SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '정류장 검색',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: themeColor, size: 18),
                      onPressed: () {
                        controller.clear();
                      },
                    )
                        : SizedBox.shrink();
                  },
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              cursorColor: themeColor,
            ),
          ),
        ],
      ),
    );
  }
}