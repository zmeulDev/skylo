import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart' show Geocoding;

/// Resolves coords to a place name using the platform's own geocoder
/// (Android `Geocoder` / Apple `CLGeocoder`) — the same data Google
/// Maps uses, and the same source Android's system location UX shows.
/// Unlike web city databases (OWM, Nominatim), it knows villages and
/// hamlets (e.g. Jucu de Sus, which OWM snaps to Apahida).
class PlatformGeocoder {
  final Geocoding _geocoding = Geocoding();

  /// Returns the locality name for [lat]/[lon], or null when the
  /// platform has no answer. Prefers locality/subLocality, then
  /// subAdminArea/adminArea.
  Future<String?> locality(
    double lat,
    double lon, {
    String locale = 'en',
  }) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lon,
          locale: locale.isEmpty ? null : Locale(locale));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final candidates = [
        p.locality,
        p.subLocality,
        p.subAdministrativeArea,
        p.administrativeArea,
      ];
      for (final candidate in candidates) {
        final name = candidate?.trim();
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[Skylo] Platform geocoder failed: $e');
      return null;
    }
  }
}