import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/bus_favorite.dart';
class FavoritesService {
  static const String _favoritesKey = 'bus_favorites';
  final uuid = Uuid();

  // 모든 즐겨찾기 불러오기
  Future<List<BusFavorite>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = prefs.getString(_favoritesKey) ?? '[]';

    try {
      final List<dynamic> jsonList = jsonDecode(favoritesJson);
      return jsonList.map((json) => BusFavorite.fromJson(json)).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  // 즐겨찾기 저장하기
  Future<void> saveFavorites(List<BusFavorite> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = jsonEncode(favorites.map((f) => f.toJson()).toList());
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  // 새 즐겨찾기 추가
  Future<BusFavorite> addFavorite(String departure, String arrival, String routeType, {String busNumber = ''}) async {
    final favorites = await getFavorites();

    // 이미 존재하는지 확인
    final exists = favorites.any((f) =>
    f.departure == departure &&
        f.arrival == arrival &&
        f.routeType == routeType
    );

    if (exists) {
      throw Exception('이미 즐겨찾기에 추가되어 있습니다.');
    }

    // 새 즐겨찾기 생성
    final newFavorite = BusFavorite(
      id: uuid.v4(),
      departure: departure,
      arrival: arrival,
      routeType: routeType,
      busNumber: busNumber,
    );

    favorites.add(newFavorite);
    await saveFavorites(favorites);

    return newFavorite;
  }

  // 즐겨찾기 삭제
  Future<void> removeFavorite(String id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.id == id);
    await saveFavorites(favorites);
  }

  // 즐겨찾기 여부 확인
  Future<bool> isFavorite(String departure, String arrival, String routeType) async {
    final favorites = await getFavorites();
    return favorites.any((f) =>
    f.departure == departure &&
        f.arrival == arrival &&
        f.routeType == routeType
    );
  }
}