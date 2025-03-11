import 'package:develoment/NaverMapScreen.dart';
import 'package:flutter/material.dart';

import 'firstScreen.dart';
import 'Chilwon.dart';
import 'Masan.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '2klgdl5i6l'); // 클라이언트 ID 추가
  runApp(MyApp());
}


class MyApp extends StatelessWidget  {
  @override
  Widget  build(BuildContext context) {
    return MaterialApp(
      title: '함안군 농어촌 버스 시간',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/location-filter': (context) => Chilwon(),
        '/location-filter2': (context) => Masan(),
        '/KakaoMapScreen': (context) => NaverMapScreen(),
      },
    );
  }
}
