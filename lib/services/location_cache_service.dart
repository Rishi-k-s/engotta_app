import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place_prediction.dart';

class LocationCacheService {
  static const String _cacheKey = 'recent_locations';
  static const int _maxCacheSize = 5;
  final SharedPreferences _prefs;

  LocationCacheService(this._prefs);

  static Future<LocationCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocationCacheService(prefs);
  }

  Future<List<PlacePrediction>> getCachedLocations() async {
    final jsonList = _prefs.getStringList(_cacheKey) ?? [];
    return jsonList.map((jsonStr) {
      final map = json.decode(jsonStr);
      return PlacePrediction(
        placeId: map['placeId'],
        mainText: map['mainText'],
        secondaryText: map['secondaryText'],
        types: List<String>.from(map['types']),
      );
    }).toList();
  }

  Future<void> addToCache(PlacePrediction location) async {
    if (location.isCurrentLocation) return; // Don't cache current location option

    final jsonList = _prefs.getStringList(_cacheKey) ?? [];
    final locations = jsonList.map((jsonStr) => json.decode(jsonStr)).toList();

    // Remove if location already exists (to move it to top)
    locations.removeWhere((loc) => loc['placeId'] == location.placeId);

    // Add new location at the beginning
    locations.insert(0, {
      'placeId': location.placeId,
      'mainText': location.mainText,
      'secondaryText': location.secondaryText,
      'types': location.types,
    });

    // Keep only the most recent locations
    if (locations.length > _maxCacheSize) {
      locations.removeRange(_maxCacheSize, locations.length);
    }

    

    // Save back to preferences
    await _prefs.setStringList(
      _cacheKey,
      locations.map((loc) => json.encode(loc)).toList(),
    );
  }

  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }
}