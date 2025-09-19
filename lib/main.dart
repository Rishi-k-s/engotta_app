import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/places_service.dart';
import 'services/location_service.dart';
import 'models/place_prediction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  late LatLng _center;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();

  Future<Iterable<PlacePrediction>> _getLocationSuggestions(String query) async {
    if (query.isEmpty) {
      return const Iterable<PlacePrediction>.empty();
    }
    try {
      final predictions = await _placesService.getPlacePredictions(
        query,
        latitude: _center.latitude,
        longitude: _center.longitude,
      );
      return predictions;
    } catch (e) {
      print('Error getting predictions: $e');
      return const Iterable<PlacePrediction>.empty();
    }
  }

  @override
  void initState() {
    super.initState();
    _center = LocationService.defaultLocation;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final location = await _locationService.getCurrentLocation();
    setState(() {
      _center = location;
    });
    mapController.animateCamera(CameraUpdate.newLatLng(_center));
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Autocomplete<PlacePrediction>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                return await _getLocationSuggestions(textEditingValue.text);
              },
              onSelected: (PlacePrediction selection) {
                _fromController.text = selection.mainText;
                // Here you would typically update the map position
              },
              displayStringForOption: (PlacePrediction option) => 
                '${option.mainText}, ${option.secondaryText}',
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'From',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
            const SizedBox(height: 8),
            Autocomplete<PlacePrediction>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                return await _getLocationSuggestions(textEditingValue.text);
              },
              onSelected: (PlacePrediction selection) {
                _toController.text = selection.mainText;
                // Here you would typically update the map position
              },
              displayStringForOption: (PlacePrediction option) => 
                '${option.mainText}, ${option.secondaryText}',
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'To',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ],
        ),
        toolbarHeight: 140, // Increased height to accommodate both fields
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
