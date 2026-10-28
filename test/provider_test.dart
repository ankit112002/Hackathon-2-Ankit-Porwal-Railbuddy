import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/data/session_store.dart';
import 'package:railbuddy/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('tripPassengersProvider emits demo passengers without hanging', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await SessionStore.create();

    final container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    // Read tripProvider
    final trip = await container.read(tripProvider.future);
    expect(trip.trainNo, equals('12345'));

    // Read tripPassengersProvider
    final passengers = await container.read(tripPassengersProvider.future);
    expect(passengers, isNotEmpty);
    expect(passengers.length, greaterThanOrEqualTo(6));

    // Verify Sharma family members exist
    final names = passengers.map((p) => p.name).toSet();
    expect(names, containsAll(['Aman', 'Bhavna', 'Chetan', 'Disha', 'Esha', 'Farhan']));
  });
}
