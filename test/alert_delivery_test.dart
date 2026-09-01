import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/data/datasources/alert_delivery_store.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';
import 'package:skylo/domain/services/alert_delivery.dart';

class _FakePrefs implements SharedPreferencesAsync {
  final Map<String, Object> values = {};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepository implements WeatherRepository {
  WeatherEntity? weather;

  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async {
    return weather!;
  }

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
      {String lang = 'en'}) async {
    return weather!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Captures what would be posted as OS notifications without touching
/// platform channels (the real service is a no-op off mobile).
class _RecordingNotifications implements NotificationBackend {
  final List<({int id, String title, String body, bool severe})> shown = [];

  @override
  Future<bool> showAlert({
    required WeatherAlert alert,
    required String title,
    required String body,
    required String placeId,
    int id = 0,
  }) async {
    shown.add((id: id, title: title, body: body, severe: alert.severe));
    return true;
  }
}

/// Test seam into [NotificationService]: lets tests intercept the
/// platform call without a real plugin.
abstract class NotificationBackend {
  Future<bool> showAlert({
    required WeatherAlert alert,
    required String title,
    required String body,
    required String placeId,
    int id = 0,
  });
}

WeatherEntity _stormyWeather() {
  final now = DateTime.now();
  return WeatherEntity(
    currentTemp: 20,
    feelsLikeTemp: 20,
    condition: 'Thunderstorm',
    weatherCode: 211,
    locationName: 'Testville',
    timeZoneOffsetSeconds: 0,
    hourly: List.generate(
      8,
      (i) => HourlyForecast(
        time: now.add(Duration(hours: i * 3 + 1)),
        temp: 20,
        precipitationProbability: 80,
        weatherCode: i < 4 ? 211 : 800,
      ),
    ),
    daily: [],
    lat: 46.7,
    lon: 23.5,
  );
}

void main() {
  late _FakePrefs prefs;
  late AlertDeliveryStore store;

  setUp(() {
    prefs = _FakePrefs();
    store = AlertDeliveryStore(prefs);
  });

  test('deliverForPlace posts new alerts once, then dedupes', () async {
    final repository = _FakeRepository()..weather = _stormyWeather();
    final backend = _RecordingNotifications();
    final delivery = _TestAlertDelivery(
      repository: repository,
      store: store,
      backend: backend,
    );

    await delivery.deliverForPlace(
      SavedPlace.current(),
      const Locale('en'),
    );
    expect(backend.shown, isNotEmpty);

    // Second round with the same weather: all keys already delivered.
    backend.shown.clear();
    await delivery.deliverForPlace(
      SavedPlace.current(),
      const Locale('en'),
    );
    expect(backend.shown, isEmpty);
  });

  test('notification title names the place, headline is localized',
      () async {
    final repository = _FakeRepository()..weather = _stormyWeather();
    final backend = _RecordingNotifications();
    final delivery = _TestAlertDelivery(
      repository: repository,
      store: store,
      backend: backend,
    );
    final place = SavedPlace(
      id: 'cluj',
      name: 'Cluj-Napoca',
      lat: 46.7,
      lon: 23.5,
    );

    await delivery.deliverForPlace(place, const Locale('en'));

    final storm = backend.shown.firstWhere(
      (n) => n.severe,
      orElse: () => throw StateError('storm must be severe'),
    );
    expect(storm.title, contains('THUNDERSTORM EXPECTED'));
    expect(storm.title, contains('Cluj-Napoca'));
  });

  test('current-location title omits the place suffix', () async {
    final repository = _FakeRepository()..weather = _stormyWeather();
    final backend = _RecordingNotifications();
    final delivery = _TestAlertDelivery(
      repository: repository,
      store: store,
      backend: backend,
    );

    await delivery.deliverForPlace(SavedPlace.current(), const Locale('en'));

    for (final n in backend.shown) {
      expect(n.title, isNot(contains('·')));
    }
  });

  test('failed fetch never throws (background contract)', () async {
    final repository = _FailingRepository();
    final delivery = _TestAlertDelivery(
      repository: repository,
      store: store,
      backend: _RecordingNotifications(),
    );

    await delivery.deliverForPlace(SavedPlace.current(), const Locale('en'));
  });

  test('stable notification id per place+kind replaces, not stacks',
      () async {
    final repository = _FakeRepository()..weather = _stormyWeather();
    final backend = _RecordingNotifications();
    final delivery = _TestAlertDelivery(
      repository: repository,
      store: store,
      backend: backend,
    );
    final place = SavedPlace(id: 'cluj', name: 'Cluj-Napoca', lat: 0, lon: 0);

    await delivery.deliverForPlace(place, const Locale('en'));
    final ids = backend.shown.map((n) => n.id).toSet();
    expect(ids.length, backend.shown.length);
  });
}

class _FailingRepository implements WeatherRepository {
  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async {
    throw Exception('network down');
  }

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
      {String lang = 'en'}) async {
    throw Exception('network down');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// [AlertDelivery] with the platform notification call intercepted.
class _TestAlertDelivery extends AlertDelivery {
  _TestAlertDelivery({
    required super.repository,
    required super.store,
    required this.backend,
  }) : super(notifications: NotificationService.instance);

  final NotificationBackend backend;

  @override
  Future<bool> postNotification({
    required WeatherAlert alert,
    required String title,
    required String body,
    required String placeId,
    int id = 0,
  }) {
    return backend.showAlert(
      alert: alert,
      title: title,
      body: body,
      placeId: placeId,
      id: id,
    );
  }
}