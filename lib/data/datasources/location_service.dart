import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skylo/domain/exceptions/location_permission_exception.dart';

class LocationService {
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[Skylo] Location services enabled: $serviceEnabled');

    var permission = await Geolocator.checkPermission();
    debugPrint('[Skylo] Location permission (initial): ${permission.name}');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[Skylo] Location permission (after request): ${permission.name}');
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(false);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(true);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.lowest),
      ).timeout(const Duration(seconds: 20));
      debugPrint('[Skylo] Position: ${position.latitude}, ${position.longitude}');
      return (latitude: position.latitude, longitude: position.longitude);
    } on TimeoutException {
      debugPrint('[Skylo] Fresh position timed out; trying last known');
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        debugPrint('[Skylo] Using last known: ${last.latitude}, ${last.longitude}');
        return (latitude: last.latitude, longitude: last.longitude);
      }
      debugPrint('[Skylo] No last known position available');
      rethrow;
    }
  }
}