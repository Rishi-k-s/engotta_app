import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/places_service.dart';
import 'services/location_service.dart';
import 'services/location_cache_service.dart';
import 'models/place_prediction.dart';
import 'utils/debouncer.dart';

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
  final Debouncer _searchDebouncer = Debouncer();
  late LocationCacheService _locationCacheService;

  Future<Iterable<PlacePrediction>> _getLocationSuggestions(String query) async {
    final normalizedQuery = query.toLowerCase();
    
    // Handle empty query - show current location and recent locations
    if (query.isEmpty) {
      final recentLocations = await _locationCacheService.getCachedLocations();
      return [
        PlacePrediction.currentLocation(),
        ...recentLocations,
      ];
    }

    // Show current location if query matches
    if ('current location'.contains(normalizedQuery)) {
      return [PlacePrediction.currentLocation()];
    }

    // For other queries, require minimum 3 characters
    if (query.length < 3) {
      return const Iterable<PlacePrediction>.empty();
    }

    // Check if query matches any recent locations
    final recentLocations = await _locationCacheService.getCachedLocations();
    final matchingRecent = recentLocations.where((location) =>
        location.mainText.toLowerCase().contains(normalizedQuery) ||
        location.secondaryText.toLowerCase().contains(normalizedQuery));

    Completer<Iterable<PlacePrediction>> completer = Completer();

    _searchDebouncer.call(() async {
      try {
        final predictions = await _placesService.getPlacePredictions(
          query,
          latitude: _center.latitude,
          longitude: _center.longitude,
        );
        if (!completer.isCompleted) {
          final results = [
            if ('current location'.contains(normalizedQuery)) 
              PlacePrediction.currentLocation(),
            ...matchingRecent,
            ...predictions.where((p) => !matchingRecent.any((r) => r.placeId == p.placeId))
          ];
          completer.complete(results);
        }
      } catch (e) {
        print('Error getting predictions: $e');
        if (!completer.isCompleted) {
          if (matchingRecent.isNotEmpty) {
            completer.complete(matchingRecent);
          } else {
            completer.complete(const Iterable<PlacePrediction>.empty());
          }
        }
      }
    });

    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    _center = LocationService.defaultLocation;
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _locationCacheService = await LocationCacheService.create();
    await _initializeLocation();
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
    _searchDebouncer.dispose();
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
              onSelected: (PlacePrediction selection) async {
                if (selection.isCurrentLocation) {
                  final currentLocation = await _locationService.getCurrentLocation();
                  setState(() {
                    _center = currentLocation;
                  });
                  mapController.animateCamera(CameraUpdate.newLatLng(_center));
                  _fromController.text = 'Current Location';
                } else {
                  _fromController.text = selection.mainText;
                  // Cache the selected location
                  await _locationCacheService.addToCache(selection);
                  // Here you would typically update the map position
                }
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
