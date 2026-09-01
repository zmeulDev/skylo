import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/data/datasources/alert_delivery_store.dart';

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

void main() {
  late _FakePrefs prefs;
  late AlertDeliveryStore store;

  setUp(() {
    prefs = _FakePrefs();
    store = AlertDeliveryStore(prefs);
  });

  test('delivers a new alert key once', () async {
    expect(
      await store.shouldDeliver('current:thunderstorm:2026-9-1',
          severe: true),
      isTrue,
    );
    // Same key again → deduped.
    expect(
      await store.shouldDeliver('current:thunderstorm:2026-9-1',
          severe: true),
      isFalse,
    );
  });

  test('severe upgrade re-delivers a previously watch-level alert',
      () async {
    expect(
      await store.shouldDeliver('cluj:heat:2026-9-1', severe: false),
      isTrue,
    );
    // Escalates past the severe threshold → notify again.
    expect(
      await store.shouldDeliver('cluj:heat:2026-9-1', severe: true),
      isTrue,
    );
    // But a second severe pass for the same day stays deduped.
    expect(
      await store.shouldDeliver('cluj:heat:2026-9-1', severe: true),
      isFalse,
    );
  });

  test('severe delivery blocks later watch delivery of the same alert',
      () async {
    expect(
      await store.shouldDeliver('cluj:cold:2026-9-1', severe: true),
      isTrue,
    );
    expect(
      await store.shouldDeliver('cluj:cold:2026-9-1', severe: false),
      isFalse,
    );
  });

  test('different places and kinds deliver independently', () async {
    expect(await store.shouldDeliver('a:heat:2026-9-1', severe: false),
        isTrue);
    expect(await store.shouldDeliver('b:heat:2026-9-1', severe: false),
        isTrue);
    expect(await store.shouldDeliver('a:fog:2026-9-1', severe: false),
        isTrue);
  });

  test('pruneExpired drops keys outside the alive set', () async {
    await store.shouldDeliver('a:heat:2026-9-1', severe: false);
    await store.shouldDeliver('a:heat:2026-9-2', severe: false);

    await store.pruneExpired({'a:heat:2026-9-2'});

    // Yesterday's marker is gone (day rolled over) — today's stays.
    expect(
      await store.shouldDeliver('a:heat:2026-9-1', severe: false),
      isTrue,
    );
    expect(
      await store.shouldDeliver('a:heat:2026-9-2', severe: false),
      isFalse,
    );
  });

  test('survives corrupted persisted JSON', () async {
    prefs.values['skylo.alertDeliveries'] = '{not json';
    expect(await store.shouldDeliver('a:heat:2026-9-1', severe: false),
        isTrue);
    // And the store rewrites clean JSON.
    final raw = prefs.values['skylo.alertDeliveries'] as String;
    expect(() => jsonDecode(raw), returnsNormally);
  });
}