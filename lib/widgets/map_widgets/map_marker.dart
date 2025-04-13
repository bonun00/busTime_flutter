import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/material.dart'; // ✅ 꼭 추가
NMarker createBusMarker(dynamic bus, {required Function() onTap}) {
  double lat = double.tryParse(bus['latitude'].toString()) ?? 0.0;
  double lng = double.tryParse(bus['longitude'].toString()) ?? 0.0;
  String vehicleId = bus['vehicleId']?.toString() ?? 'unknown';
  String busNumber = bus['busNumber']?.toString() ?? '';

  final marker = NMarker(
    id: vehicleId,
    position: NLatLng(lat, lng),
    caption: NOverlayCaption(
      text: busNumber,
      textSize: 14,
      color: Colors.white,
      haloColor:Colors.black
    ),
    icon: const NOverlayImage.fromAssetImage('assets/images/bus_marker.png'),
  );

  marker.setOnTapListener((_) => onTap());

  return marker;
}

NMarker createStopMarker(dynamic stop, {required Function() onTap}) {
  final marker = NMarker(
    id: stop['nodeId'],
    position: NLatLng(stop['latitude'], stop['longitude']),
    caption: NOverlayCaption(
      text: stop['nodeNm'],
      textSize: 12,
      color: Colors.black,
      haloColor: Colors.white
    ),
    icon: const NOverlayImage.fromAssetImage('assets/images/big-location-marker.png'),
  );

  marker.setOnTapListener((_) => onTap());

  return marker;
}