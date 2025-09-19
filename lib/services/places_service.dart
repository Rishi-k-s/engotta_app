import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_prediction.dart';
import '../config/api_keys.dart';

class PlacesService {
  static const String _baseUrl = 'places.googleapis.com';
  static const String _autocompletePath = '/v1/places:autocomplete';
  static final String _apiKey = ApiKeys.googlePlacesApi;

  Future<List<PlacePrediction>> getPlacePredictions(
    String input,
    {
    double? latitude,
    double? longitude,
    double radius = 500.0,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'input': input,
        'locationBias': {
          'circle': {
            'center': {
              'latitude': latitude ?? 12.8539832,
              'longitude': longitude ?? 77.7786213,
            },
            'radius': radius,
          },
        },
        'includedRegionCodes': ['in'],
        'includeQueryPredictions': true,
      };

      final uri = Uri.https(_baseUrl, _autocompletePath);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List;
        return suggestions
            .map((suggestion) => PlacePrediction.fromJson(suggestion))
            .toList();
      } else {
        throw Exception('Failed to fetch place predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching place predictions: $e');
    }
  }
}
