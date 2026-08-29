class LocationPermissionException implements Exception {
  final bool permanently;

  const LocationPermissionException(this.permanently);

  @override
  String toString() => permanently
      ? 'Location access is disabled for Skylo. Enable it in System Settings → Privacy & Security → Location Services.'
      : 'Skylo needs location permission to show your local weather.';
}