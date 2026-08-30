import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skylo/domain/exceptions/location_permission_exception.dart';

class LocationService {
  /// The coords we last served, used by [revalidate] to detect movement.
  ({double latitude, double longitude})? _lastReturned;

  /// Resolves fast: cached last-known position first (instant), fresh GPS
  /// fix only when nothing is cached (cold start).
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[Skylo] Location services enabled: $serviceEnabled');

    var permission = await Geolocator.checkPermission();
    debugPrint('[Skylo] Location permission (initial): ${permission.name}');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint(
          '[Skylo] Location permission (after request): ${permission.name}');
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(false);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(true);
    }

    // Fast path: cached position — weather for "here" is better shown now
    // than a spinner for 20 seconds. [revalidate] corrects it if stale.
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      debugPrint(
          '[Skylo] Fast location (cached): ${last.latitude}, ${last.longitude}');
      _lastReturned = (latitude: last.latitude, longitude: last.longitude);
      return _lastReturned!;
    }

    return _freshFix();
  }

  Future<({double latitude, double longitude})> _freshFix() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.lowest),
    ).timeout(const Duration(seconds: 15));
    debugPrint('[Skylo] Fresh position: ${position.latitude}, ${position.longitude}');
    _lastReturned = (latitude: position.latitude, longitude: position.longitude);
    return _lastReturned!;
  }

  /// Stale-while-revalidate: fetch a fresh fix and compare it with the
  /// last coords we served (e.g. the app was opened after a 20km drive —
  /// the cached position still points at home). Returns the new coords
  /// when the device has moved beyond [thresholdMeters], else null.
  Future<({double latitude, double longitude})?> revalidate(
      {double thresholdMeters = 1500}) async {
    final last = _lastReturned;
    if (last == null) return null;
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.lowest),
      ).timeout(const Duration(seconds: 12));
      final moved = Geolocator.distanceBetween(
          last.latitude, last.longitude, fresh.latitude, fresh.longitude);
      debugPrint('[Skylo] Revalidate: moved ${moved.round()}m');
      if (moved > thresholdMeters) {
        _lastReturned =
            (latitude: fresh.latitude, longitude: fresh.longitude);
        return _lastReturned!;
      }
    } on TimeoutException {
      debugPrint('[Skylo] Revalidate timed out — keeping cached coords');
    } catch (e) {
      debugPrint('[Skylo] Revalidate failed: $e');
    }
    return null;
  }
}