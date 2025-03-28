// import 'package:flutter/material.dart';
// import 'services/busApiService.dart'; // API 서비스 파일 추가
//
// class Masan extends StatefulWidget {
//   @override
//   _MasanState createState() => _MasanState();
// }
//
// class _MasanState extends State<Masan> {
//   final BusApiService _busApiService = BusApiService();
//
//   List<dynamic> _busSchedule = [];
//   Map<String, List<dynamic>> _busRoutes = {}; // 노선 데이터 저장
//   List<String> _stops = [];
//   bool _isLoading = false;
//   String? _selectedStop;
//   String? _selectedBusNumber;
//   String? _expandedTime; // 현재 펼쳐진 시간 (토글용)
//
//   final List<String> _busNumbers = ['113', '250']; // 버스 번호 리스트
//   int _selectedBusIndex = -1; // 선택된 버스 번호 인덱스
//
//   @override
//   void initState() {
//     super.initState();
//     _loadStops();
//   }
//
//   // 마산 정류장 목록 불러오기
//   Future<void> _loadStops() async {
//     List<dynamic> stops = await _busApiService.fetchMasanStops();
//     setState(() {
//       _stops = stops.map((e) => e['stopName'].toString()).toList();
//     });
//     print(stops);
//   }
//
//   // 버스 시간표 불러오기
//   Future<void> _fetchBusSchedule() async {
//     if (_selectedBusNumber == null || _selectedStop == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("버스 번호와 정류장을 선택해주세요!")),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     List<dynamic> schedule =
//     await _busApiService.fetchMasanTimes(_selectedBusNumber!, _selectedStop!);
//
//     setState(() {
//       _busSchedule = schedule;
//       _isLoading = false;
//     });
//   }
//
//   // 상세 노선 불러오기 (클릭한 시간에 대한 데이터 요청)
//   Future<void> _fetchBusRoute(String time, String busNumber) async {
//     // 이미 선택된 시간일 경우 닫기 (토글 기능)
//     if (_expandedTime == time) {
//       setState(() {
//         _expandedTime = null;
//       });
//       return;
//     }
//
//     print("선택된 버스 번호: $busNumber, 도착 시간: $time");
//
//     String sendTime=time+":00";
//     // 새 시간 선택 시, API 요청 (두 번째 매개변수로 time을 전달)
//     if (!_busRoutes.containsKey(time)) {
//       List<dynamic> route = await _busApiService.fetchMasanRoute(busNumber, sendTime);
//       setState(() {
//         _busRoutes[time] = route;
//       });
//     }
//
//     setState(() {
//       _expandedTime = time;
//     });
//   }
//
//   // HH:mm:ss 형태의 문자열을 HH:mm으로 변환하는 함수
//   String _formatTime(String time) {
//     return time.length >= 5 ? time.substring(0, 5) : time;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green[50],
//       appBar: AppBar(
//         title: Text('삼칠/대산 ▶ 창원/마산'),
//         backgroundColor: Color(0xff388e3c),
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 버스 번호 선택 (토글 버튼)
//             Text(
//               '🚍 버스 번호',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Color(0xff388e3c),
//               ),
//             ),
//             SizedBox(height: 10),
//             Center(
//               child: ToggleButtons(
//                 borderRadius: BorderRadius.circular(10),
//                 selectedColor: Colors.white,
//                 fillColor: Color(0xff388e3c),
//                 color: Color(0xff388e3c),
//                 isSelected: List.generate(
//                   _busNumbers.length,
//                       (index) => index == _selectedBusIndex,
//                 ),
//                 children: _busNumbers
//                     .map((bus) => Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 8.0),
//                   child: Text(
//                     bus,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ))
//                     .toList(),
//                 onPressed: (int index) {
//                   setState(() {
//                     _selectedBusIndex = index;
//                     _selectedBusNumber = _busNumbers[index];
//                     _busSchedule = []; // 선택 변경 시 기존 데이터 초기화
//                   });
//                   _fetchBusSchedule();
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             // 정류장 선택 (드롭다운 버튼)
//             Text(
//               '🚏 정류장 선택',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Color(0xff388e3c),
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Color(0xff388e3c)),
//               ),
//               child: DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text(
//                   '정류장을 선택하세요',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 value: _selectedStop,
//                 underline: SizedBox(),
//                 dropdownColor: Colors.white,
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//                 items: _stops.map((stop) {
//                   return DropdownMenuItem<String>(
//                     value: stop,
//                     child: Text(
//                       stop,
//                       style: TextStyle(
//                         color: Color(0xff388e3c),
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedStop = newValue;
//                   });
//                   _fetchBusSchedule();
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             // 버스 시간표
//             _isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : _busSchedule.isEmpty
//                 ? Center(
//               child: Text(
//                 '버스 시간표가 없습니다.',
//                 style: TextStyle(
//                     color: Colors.grey[700], fontSize: 16),
//               ),
//             )
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _busSchedule.length,
//                 itemBuilder: (context, index) {
//                   var bus = _busSchedule[index];
//                   // 도착 시간을 HH:mm 형식으로 변환
//                   String time = _formatTime(bus['arrivalTime']);
//                   return Column(
//                     children: [
//                       // 버스 시간 클릭 시 노선 보기
//                       Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 3,
//                         margin: EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           contentPadding: EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           title: Text(
//                             '🕒 시간: $time',
//                             style: TextStyle(
//                                 color: Color(0xff388e3c),
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             '🚍 버스 번호: ${bus['busNumber']}',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           trailing: Icon(
//                             _expandedTime == time
//                                 ? Icons.expand_less
//                                 : Icons.expand_more,
//                             color: Color(0xff388e3c),
//                           ),
//                           onTap: () =>
//                               _fetchBusRoute(time, bus['busNumber']),
//                         ),
//                       ),
//                       // 노선 리스트 (시간 선택 시만 표시)
//                       if (_expandedTime == time &&
//                           _busRoutes.containsKey(time))
//                         Container(
//                           margin: EdgeInsets.only(
//                               bottom: 8, left: 8, right: 8),
//                           padding: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: Color(0xff388e3c)),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: _busRoutes[time]!
//                                 .map((stop) {
//                               // 노선의 도착 예정 시간도 HH:mm으로 변환
//                               String stopTime = _formatTime(stop['arrivalTime']);
//                               return ListTile(
//                                 dense: true,
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                                 leading: Icon(Icons.directions_bus,
//                                     color: Color(0xff388e3c)),
//                                 title: Text(
//                                   '${stop['stopName']}',
//                                   style: TextStyle(
//                                       color: Color(0xff388e3c),
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                                 subtitle: Text(
//                                   '도착 예정 시간: $stopTime',
//                                   style: TextStyle(
//                                       color: Colors.black87, fontSize: 13),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }