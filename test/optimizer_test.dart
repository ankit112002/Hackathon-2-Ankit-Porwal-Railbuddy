import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/logic/optimizer.dart';
import 'package:railbuddy/models/passenger.dart';

void main() {
  group('Optimizer Tests', () {
    final sharmaFamily = [
      const Passenger(
          id: 'aman',
          tripId: 't1',
          groupId: 'g1',
          name: 'Aman',
          coach: 'S1',
          seatNo: 23,
          willingToSwap: true),
      const Passenger(
          id: 'bhavna',
          tripId: 't1',
          groupId: 'g1',
          name: 'Bhavna',
          coach: 'S2',
          seatNo: 41,
          willingToSwap: true),
      const Passenger(
          id: 'chetan',
          tripId: 't1',
          groupId: 'g1',
          name: 'Chetan',
          coach: 'S2',
          seatNo: 42,
          willingToSwap: true),
      const Passenger(
          id: 'disha',
          tripId: 't1',
          groupId: 'g1',
          name: 'Disha',
          coach: 'S3',
          seatNo: 56,
          willingToSwap: true),
      const Passenger(
          id: 'esha',
          tripId: 't1',
          groupId: 'g1',
          name: 'Esha',
          coach: 'S4',
          seatNo: 21,
          willingToSwap: true),
      const Passenger(
          id: 'farhan',
          tripId: 't1',
          groupId: 'g1',
          name: 'Farhan',
          coach: 'S5',
          seatNo: 37,
          willingToSwap: true),
    ];

    List<Passenger> getVolunteers({bool pWilling = true}) => [
          Passenger(
              id: 'p',
              tripId: 't1',
              name: 'Passenger P',
              coach: 'S2',
              seatNo: 43,
              willingToSwap: pWilling),
          Passenger(
              id: 'q',
              tripId: 't1',
              name: 'Passenger Q',
              coach: 'S2',
              seatNo: 44,
              willingToSwap: pWilling),
          Passenger(
              id: 'r',
              tripId: 't1',
              name: 'Passenger R',
              coach: 'S2',
              seatNo: 45,
              willingToSwap: pWilling),
          Passenger(
              id: 's',
              tripId: 't1',
              name: 'Passenger S',
              coach: 'S2',
              seatNo: 46,
              willingToSwap: pWilling),
          const Passenger(
              id: 't',
              tripId: 't1',
              name: 'Passenger T',
              coach: 'S2',
              seatNo: 47,
              willingToSwap: false),
          const Passenger(
              id: 'u',
              tripId: 't1',
              name: 'Passenger U',
              coach: 'S2',
              seatNo: 48,
              willingToSwap: false),
        ];

    test('seed data returns S2 bay 5 plan with 4 swaps and targetScore 100', () {
      final allPassengers = [...sharmaFamily, ...getVolunteers(pWilling: true)];
      final plan = bestPlan(group: sharmaFamily, all: allPassengers);

      expect(plan, isNotNull);
      expect(plan!.coach, equals('S2'));
      expect(plan.bay, equals(5));
      expect(plan.swaps.length, equals(4));
      expect(plan.targetScore, equals(100));

      final swappedMembers = plan.swaps.map((s) => s.member.name).toSet();
      expect(swappedMembers, containsAll(['Aman', 'Disha', 'Esha', 'Farhan']));
    });

    test('when volunteers in bay are not willing, falls back to null or coach plan', () {
      final allPassengers = [...sharmaFamily, ...getVolunteers(pWilling: false)];
      final plan = bestPlan(group: sharmaFamily, all: allPassengers);

      // Since there are no other willing passengers in S2, plan should be null
      expect(plan, isNull);
    });
  });
}
