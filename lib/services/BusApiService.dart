import 'package:dio/dio.dart';
import 'dart:convert';
class BusApiService {
  final Dio _dio = Dio();

  // 📌 Android Emulator -> 10.0.2.2 사용
  // 📌 iOS Simulator -> 127.0.0.1 사용
  static const String _baseUrl = "https://63c8-218-146-45-168.ngrok-free.app/bus";


  Future<List<dynamic>> fetchPath() async {
    try {


      Response response = await _dio.get("$_baseUrl/path");

      // 서버 응답이 정상적인지 출력
      final List<dynamic> pathData = response.data;
      return pathData;
    } catch (e) {
      print("버스경로 에러 발생: $e");
      return [];
    }
  }


  Future<List<dynamic>> fetchStopTime(String nodeId) async {
    try {


      Response response = await _dio.get("$_baseUrl/arrival",
          queryParameters: { "nodeId": nodeId});

      // 서버 응답이 정상적인지 출력
      final List<dynamic> pathData = response.data;
      return pathData;
    } catch (e) {
      print("버스경로 에러 발생: $e");
      return [];
    }
  }




  // ✅ 마산 도착 시간 조회
  Future<List<dynamic>> fetchMasanTimes(String busNumber,
      String stopName) async {
    try {
      Response response = await _dio.get("$_baseUrl/masan-times",
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

  Future<List<dynamic>> fetchMasanRoute(String busNumber, String arrivalTime) async {
    try {
      Response response = await _dio.get(
        "$_baseUrl/masan-route",
        queryParameters: {
          "busNumber": busNumber,
          "arriveTime": arrivalTime,
        },
      );
      return response.data;
    } catch (e) {
      print("🚨 마산 노선 불러오기 실패: $e");
      return [];
    }
  }

// ✅ 칠원 버스 노선 조회
  Future<List<dynamic>> fetchChilwonRoute(String busNumber, String arrivalTime) async {
    try {
      Response response = await _dio.get(
        "$_baseUrl/chilwon-route",
        queryParameters: {
          "busNumber": busNumber,
          "arriveTime":arrivalTime
        },

      );
      return response.data;
    } catch (e) {
      print("🚨 칠원 노선 불러오기 실패: $e");
      return [];
    }
  }
  /// [1] 칠원 정류장 검색 API
  ///   - 예: GET /search-chilwon-stops?query=xxx
  Future<List<Map<String, dynamic>>> searchChilwonStops(String query) async {
    try {

      final response = await _dio.get(
        "$_baseUrl/search-chilwon-stops",
        queryParameters: {"query": query},
      );
      final List data = response.data; // raw: List<dynamic>
      // Map<String,dynamic> 로 캐스팅
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("칠원 정류장 검색 에러: $e");
      return [];
    }
  }

  /// [2] 마산 정류장 검색 API
  ///   - 예: GET /search-masan-stops?query=xxx
  Future<List<Map<String, dynamic>>> searchMasanStops(String query) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/search-masan-stops",
        queryParameters: {"query": query},
      );
      final List data = response.data; // raw: List<dynamic>
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("마산 정류장 검색 에러: $e");
      return [];
    }
  }

  //////// [2] 칠원 노선: 출발/도착 정류장으로 시간표 조회
  //    응답도 List<Map<String,dynamic>> 라고 가정
  Future<List<Map<String, dynamic>>> fetchChilwonRouteSchedules(
      String departureStopId, String arrivalStopId) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/route-chilwon-schedules",
        queryParameters: {
          "departureStop": departureStopId,
          "arrivalStop": arrivalStopId,
        },
      );
      final List data = response.data; // List<dynamic>
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("칠원 노선 조회 에러: $e");
      return [];
    }
  }

  // [3] 마산 노선: 출발/도착 정류장으로 시간표 조회
  Future<List<Map<String, dynamic>>> fetchMasanRouteSchedules(
      String departureStopId, String arrivalStopId) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/route-masan-schedules",
        queryParameters: {
          "departureStop": departureStopId,
          "arrivalStop": arrivalStopId,
        },
      );
      final List data = response.data; // List<dynamic>
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("마산 노선 조회 에러: $e");
      return [];
    }
  }
  /// 출발지/도착지 ID로 버스 시간표 조회
  Future<List<Map<String, dynamic>>> fetchRouteSchedules(
      int departureStopId, int arrivalStopId) async {
    try {
      final response = await _dio.get(
        "$_baseUrl/route-chilwon-schedules",
        queryParameters: {
          "departureStop": departureStopId,
          "arrivalStop": arrivalStopId,
        },
      );
      // 예: [{"departureTime":"07:10","arrivalTime":"08:00","busNumber":"113"}, ...]
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("fetchRouteSchedules() 에러: $e");
      return [];
    }
  }

}