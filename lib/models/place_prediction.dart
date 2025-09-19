class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'];
    return PlacePrediction(
      placeId: prediction['placeId'] as String,
      mainText: prediction['structuredFormat']['mainText']['text'] as String,
      secondaryText: prediction['structuredFormat']['secondaryText']['text'] as String,
      types: (prediction['types'] as List).map((e) => e as String).toList(),
    );
  }
}
