import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경에 그라데이션 효과 적용 (선택 사항)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[200]!, Colors.green[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '함안 마산 버스 시간',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff388e3c),
                  ),
                ),
                SizedBox(height: 40),
                _buildMenuButton(
                  context,
                  text: '삼칠/대산 ▶ 창원/마산 🚌',
                  routeName: '/location-filter2',
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  text: '창원/마산 ▶ 삼칠/대산 🚌',
                  routeName: '/location-filter',
                ),
                SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  text: '실시간 버스위치 조회',
                  routeName: '/KakaoMapScreen',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String text, required String routeName}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff388e3c),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}