import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/logic/score.dart';
import 'package:railbuddy/models/passenger.dart';

void main() {
  group('Score Tests', () {
    final sharmaFamily = [
      const Passenger(
          id: '1',
          tripId: 't1',
          name: 'Aman',
          coach: 'S1',
          seatNo: 23,
          willingToSwap: true),
      const Passenger(
          id: '2',
          tripId: 't1',
          name: 'Bhavna',
          coach: 'S2',
          seatNo: 41,
          willingToSwap: true),
      const Passenger(
          id: '3',
          tripId: 't1',
          name: 'Chetan',
          coach: 'S2',
          seatNo: 42,
          willingToSwap: true),
      const Passenger(
          id: '4',
          tripId: 't1',
          name: 'Disha',
          coach: 'S3',
          seatNo: 56,
          willingToSwap: true),
      const Passenger(
          id: '5',
          tripId: 't1',
          name: 'Esha',
          coach: 'S4',
          seatNo: 21,
          willingToSwap: true),
      const Passenger(
          id: '6',
          tripId: 't1',
          name: 'Farhan',
          coach: 'S5',
          seatNo: 37,
          willingToSwap: true),
    ];

    test('scattered group scores 20', () {
      expect(groupScore(sharmaFamily), equals(20));
      expect(coachSpread(sharmaFamily), equals(5));
    });

    test('all in same bay scores 100', () {
      final sameBay = [
        const Passenger(
            id: '1',
            tripId: 't1',
            name: 'Aman',
            coach: 'S2',
            seatNo: 41,
            willingToSwap: true),
        const Passenger(
            id: '2',
            tripId: 't1',
            name: 'Bhavna',
            coach: 'S2',
            seatNo: 42,
            willingToSwap: true),
        const Passenger(
            id: '3',
            tripId: 't1',
            name: 'Chetan',
            coach: 'S2',
            seatNo: 43,
            willingToSwap: true),
        const Passenger(
            id: '4',
            tripId: 't1',
            name: 'Disha',
            coach: 'S2',
            seatNo: 44,
            willingToSwap: true),
        const Passenger(
            id: '5',
            tripId: 't1',
            name: 'Esha',
            coach: 'S2',
            seatNo: 45,
            willingToSwap: true),
        const Passenger(
            id: '6',
            tripId: 't1',
            name: 'Farhan',
            coach: 'S2',
            seatNo: 46,
            willingToSwap: true),
      ];
      expect(groupScore(sameBay), equals(100));
    });

    test('same coach different bays scores 80', () {
      final sameCoach = [
        const Passenger(
            id: '1',
            tripId: 't1',
            name: 'Aman',
            coach: 'S2',
            seatNo: 1,
            willingToSwap: true),
        const Passenger(
            id: '2',
            tripId: 't1',
            name: 'Bhavna',
            coach: 'S2',
            seatNo: 41,
            willingToSwap: true),
      ];
      expect(groupScore(sameCoach), equals(80));
    });

    test('adjacent coaches scores 60', () {
      final adjacent = [
        const Passenger(
            id: '1',
            tripId: 't1',
            name: 'Aman',
            coach: 'S1',
            seatNo: 1,
            willingToSwap: true),
        const Passenger(
            id: '2',
            tripId: 't1',
            name: 'Bhavna',
            coach: 'S2',
            seatNo: 1,
            willingToSwap: true),
      ];
      expect(groupScore(adjacent), equals(60));
    });
  });
}
