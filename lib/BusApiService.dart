import 'package:dio/dio.dart';

class BusApiService {
  final Dio _dio = Dio();

  // 📌 Android Emulator -> 10.0.2.2 사용
  // 📌 iOS Simulator -> 127.0.0.1 사용
  static const String _baseUrl = "http://10.0.2.2:1111/bus";

  // ✅ 마산 도착 시간 조회
  Future<List<dynamic>> fetchMasanTimes(String busNumber,
      String stopName) async {
    try {
      Response response = await _dio.get("$_baseUrl/Masan-times",
          queryParameters: {"busNumber": busNumber, "stopName": stopName});

      return response.data;
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  // ✅ 칠원 도착 시간 조회
  Future<List<dynamic>> fetchChilwonTimes(String busNumber,
      String stopName) async {
    try {
      Response response = await _dio.get("$_baseUrl/chilwon-times",
          queryParameters: {"busNumber": busNumber, "stopName": stopName});

      return response.data;
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  // ✅ 마산 정류장 목록 조회
  Future<List<dynamic>> fetchMasanStops() async {
    try {
      Response response = await _dio.get("$_baseUrl/masan-stops");
      return response.data;
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  // ✅ 칠원 정류장 목록 조회
  Future<List<dynamic>> fetchChilwonStops() async {
    try {
      Response response = await _dio.get("$_baseUrl/chilwon-stops");
      return response.data;
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }



  Future<List<dynamic>> fetchMasanRoute(String busNumber) async {
    try {
      Response response = await _dio.get(
        "$_baseUrl/masan-route",
        queryParameters: {"busNumber": busNumber},
      );
      return response.data;
    } catch (e) {
      print("🚨 마산 노선 불러오기 실패: $e");
      return [];
    }
  }

// ✅ 칠원 버스 노선 조회
  Future<List<dynamic>> fetchChilwonRoute(String busNumber) async {
    try {
      Response response = await _dio.get(
        "$_baseUrl/chilwon-route",
        queryParameters: {"busNumber": busNumber},
      );
      return response.data;
    } catch (e) {
      print("🚨 칠원 노선 불러오기 실패: $e");
      return [];
    }
  }
}