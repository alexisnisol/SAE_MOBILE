import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _userPosition;
  bool _isLoading = false;
  String? _error;

  static const double _defaultLatitude = 47.902964;
  static const double _defaultLongitude = 1.909251;

  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getUserLocation(isGeolocationDisabled) async {
    try {
      _isLoading = true;
      _error = null;

      if (isGeolocationDisabled) {
        _setDefaultPosition();
        _error = 'Service de localisation désactivé';
        return;
      }

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled) {
        _setDefaultPosition();
        _error = 'Service de localisation désactivé';
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _setDefaultPosition();
        _error = 'Permissions de localisation requises';
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      _setDefaultPosition();
      _error = 'Impossible de déterminer la position';
    } finally {
      _isLoading = false;
    }
  }

  void _setDefaultPosition() {
    _userPosition = Position(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  bool get hasValidPosition {
    return _userPosition != null &&
        !isUsingDefaultLocation() &&
        _userPosition!.latitude != 0 &&
        _userPosition!.longitude != 0;
  }

  double? calculateDistanceTo(double latitude, double longitude) {
    if (!hasValidPosition) return null;

    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          latitude,
          longitude,
        ) /
        1000;
  }

  bool isUsingDefaultLocation() {
    return _userPosition?.latitude == _defaultLatitude &&
        _userPosition?.longitude == _defaultLongitude;
  }
}
