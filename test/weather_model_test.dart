import 'package:flutter_test/flutter_test.dart';
import 'package:skylo/data/datasources/open_weather_remote_data_source.dart';
import 'package:skylo/data/models/weather_model.dart';

void main() {
  final onecallJson = {
    'timezone_offset': 0,
    'current': {
      'dt': 1750000000,
      'temp': 21.5,
      'feels_like': 20.9,
      'weather': [
        {'id': 800, 'main': 'Clear'},
      ],
    },
    'hourly': List.generate(
      24,
      (i) => {
        'dt': 1750000000 + i * 3600,
        'temp': 18.0 + i * 0.5,
        'pop': 0.1 * (i % 3),
        'weather': [
          {'id': i % 2 == 0 ? 500 : 800},
        ],
      },
    ),
    'daily': List.generate(
      7,
      (i) => {
        'dt': 1750000000 + i * 86400,
        'temp': {'max': 25.0 + i, 'min': 15.0 + i},
        'weather': [
          {'id': 800},
        ],
      },
    ),
  };

  final currentJson = {
    'name': 'Cluj-Napoca',
    'dt': 1750000000,
    'main': {'temp': 21.5, 'feels_like': 20.9, 'temp_min': 19.0, 'temp_max': 23.0},
    'weather': [
      {'id': 800, 'main': 'Clear'},
    ],
  };

  final forecastJson = {
    'list': List.generate(
      8,
      (i) => {
        'dt': 1750000000 + i * 10800,
        'main': {'temp': 20.0 + i, 'temp_min': 19.0, 'temp_max': 21.0 + i},
        'pop': (i % 3) * 0.2,
        'weather': [
          {'id': i.isEven ? 500 : 800, 'main': 'Rain'},
        ],
      },
    ),
  };

  test('fromJson maps payload to WeatherEntity fields', () {
    final model = WeatherModel.fromJson(onecallJson);

    expect(model.currentTemp, 21.5);
    expect(model.feelsLikeTemp, 20.9);
    expect(model.condition, 'Clear');
    expect(model.weatherCode, 800);
    expect(model.hourly.length, 24);
    expect(model.hourly.first.temp, 18.0);
    expect(model.hourly.first.precipitationProbability, closeTo(0, 0.001));
    expect(model.hourly[1].precipitationProbability, closeTo(10, 0.001));
    expect(model.daily.length, 7);
    expect(model.daily.first.maxTemp, 25.0);
    expect(model.daily.first.minTemp, 15.0);
  });

  test('daily forecast buckets hourly entries into matching days', () {
    final model = WeatherModel.fromJson(onecallJson);
    final total = model.daily.fold<int>(0, (sum, d) => sum + d.hours.length);
    expect(total, 24);
    expect(model.daily.first.hours, isNotEmpty);
    // Every hour belongs to exactly one day, and that day's date matches
    // the hour's wall-clock calendar date.
    final bucketedByHourDate = <String, int>{};
    for (final day in model.daily) {
      for (final hour in day.hours) {
        final key =
            '${hour.time.year}-${hour.time.month}-${hour.time.day}';
        bucketedByHourDate[key] = (bucketedByHourDate[key] ?? 0) + 1;
        expect(day.date.day, hour.time.day,
            reason: 'hour ${hour.time} landed in day ${day.date}');
      }
    }
    // 24 sequential hourly entries span at most 2 calendar dates.
    expect(bucketedByHourDate.length, lessThanOrEqualTo(2));
  });

  test('toJson round-trips scalar fields', () {
    final model = WeatherModel.fromJson(onecallJson);
    final out = model.toJson();

    expect(out['current']['temp'], 21.5);
    expect(out['current']['feels_like'], 20.9);
    expect(out['current']['weather'][0]['main'], 'Clear');
    expect(out['current']['weather'][0]['id'], 800);
    expect((out['hourly'] as List).length, 24);
    expect((out['daily'] as List).length, 7);
    expect(out['daily'][0]['temp']['max'], 25.0);
  });

  test('fromJson tolerates missing hourly/daily', () {
    final minimal = {
      'current': {
        'temp': 10,
        'feels_like': 9,
        'weather': [
          {'id': 803, 'main': 'Clouds'},
        ],
      },
    };
    final model = WeatherModel.fromJson(minimal);

    expect(model.currentTemp, 10);
    expect(model.hourly, isEmpty);
    expect(model.daily, isEmpty);
  });

  test('merge converts free 2.5 endpoints into One Call shape', () {
    final merged = OpenWeatherRemoteDataSource.mergeToOnecallShape(
        currentJson, forecastJson);
    final model = WeatherModel.fromJson(merged);

    expect(model.currentTemp, 21.5);
    expect(model.feelsLikeTemp, 20.9);
    expect(model.condition, 'Clear');
    expect(model.weatherCode, 800);

    expect(model.hourly.length, 8);
    expect(model.hourly.first.temp, 20.0);
    expect(model.hourly[1].precipitationProbability, closeTo(20, 0.001));

    expect(model.daily.length, greaterThanOrEqualTo(1));
    expect(model.daily.first.maxTemp, closeTo(23.0, 0.5));
  });

  test('merged daily entries never have null weather', () {
    final merged = OpenWeatherRemoteDataSource.mergeToOnecallShape(
        currentJson, forecastJson);
    for (final day in merged['daily'] as List) {
      expect((day['weather'] as List).first, isNotNull);
    }
  });
}