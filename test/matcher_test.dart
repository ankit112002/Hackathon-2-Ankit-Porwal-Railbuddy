import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/logic/matcher.dart';
import 'package:railbuddy/models/passenger.dart';

void main() {
  group('Matcher Tests', () {
    const aman = Passenger(
      id: 'aman',
      tripId: 't1',
      name: 'Aman',
      coach: 'S1',
      seatNo: 23,
      willingToSwap: true,
      groupId: 'g1',
    );

    const bhavna = Passenger(
      id: 'bhavna',
      tripId: 't1',
      name: 'Bhavna',
      coach: 'S2',
      seatNo: 41,
      willingToSwap: true,
      groupId: 'g1',
    );

    const rahul = Passenger(
      id: 'rahul',
      tripId: 't1',
      name: 'Rahul',
      coach: 'S1',
      seatNo: 24,
      willingToSwap: true,
    );

    const karan = Passenger(
      id: 'karan',
      tripId: 't1',
      name: 'Karan',
      coach: 'S1',
      seatNo: 22,
      willingToSwap: false,
    );

    const sunita = Passenger(
      id: 'sunita',
      tripId: 't1',
      name: 'Sunita',
      coach: 'S3',
      seatNo: 57,
      willingToSwap: true,
    );

    final allPassengers = [aman, bhavna, rahul, karan, sunita];
    final group = [aman, bhavna];

    test('for Aman with preferred berth Lower and sameCoachOnly, Rahul (S1/24) is ranked first; non-willing passengers are excluded; group members are excluded', () {
      final matches = findMatches(
        me: aman,
        all: allPassengers,
        group: group,
        preferredBerth: 'Lower',
        sameCoachOnly: true,
        onlyOpen: true,
      );

      expect(matches, isNotEmpty);
      expect(matches.first.passenger.id, equals('rahul'));
      // Karan is not willing so excluded
      expect(matches.any((m) => m.passenger.id == 'karan'), isFalse);
      // Bhavna is in the group so excluded
      expect(matches.any((m) => m.passenger.id == 'bhavna'), isFalse);
      // Aman itself is excluded
      expect(matches.any((m) => m.passenger.id == 'aman'), isFalse);
      // Sunita is in S3 so excluded when sameCoachOnly is true
      expect(matches.any((m) => m.passenger.id == 'sunita'), isFalse);
    });

    test('findMatches excludes non-willing passengers when onlyOpen is true', () {
      final matches = findMatches(
        me: aman,
        all: allPassengers,
        group: group,
        onlyOpen: true,
      );
      expect(matches.any((m) => m.passenger.id == 'karan'), isFalse);
    });
  });
}
