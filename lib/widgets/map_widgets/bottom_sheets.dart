import 'package:flutter/material.dart';

void showBusInfoBottomSheet(BuildContext context, dynamic bus) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${bus['busNumber']}번 버스", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("차량 ID: ${bus['vehicleId']}"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("닫기"),
          )
        ],
      ),
    ),
  );
}

void showStopArrivalSheet(BuildContext context, String stopName, List<dynamic> arrivalInfo) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$stopName 정류장 도착 정보",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          arrivalInfo.isEmpty
              ? Text("도착 예정 버스가 없습니다.")
              : ListView.builder(
            shrinkWrap: true,
            itemCount: arrivalInfo.length,
            itemBuilder: (context, index) {
              final info = arrivalInfo[index];
              return ListTile(
                leading: Icon(Icons.directions_bus, color: Colors.green),
                title: Text("${info['routeNo']}번 (${info['routeTp']})"),
                subtitle: Text("도착까지 ${info['arrTime']}분 | 남은 정류장 ${info['arrPrevStationCnt']}개"),
              );
            },
          ),
        ],
      ),
    ),
  );
}