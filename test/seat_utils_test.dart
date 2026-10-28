import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/logic/seat_utils.dart';

void main() {
  group('Seat Utils Tests', () {
    test('bayOf calculations', () {
      expect(bayOf(41), equals(5));
      expect(bayOf(48), equals(5));
      expect(bayOf(49), equals(6));
      expect(bayOf(1), equals(0));
      expect(bayOf(8), equals(0));
      expect(bayOf(9), equals(1));
    });

    test('berthOf calculations', () {
      expect(berthOf(1), equals('Lower'));
      expect(berthOf(2), equals('Middle'));
      expect(berthOf(3), equals('Upper'));
      expect(berthOf(4), equals('Lower'));
      expect(berthOf(5), equals('Middle'));
      expect(berthOf(6), equals('Upper'));
      expect(berthOf(7), equals('Side Lower'));
      expect(berthOf(8), equals('Side Upper'));
    });

    test('coachNo and labels', () {
      expect(coachNo('S1'), equals(1));
      expect(coachNo('S2'), equals(2));
      expect(coachNo('S5'), equals(5));
      expect(seatLabel('S2', 43), equals('S2 / 43'));
      expect(seatKey('S2', 43), equals('S2/43'));
    });

    test('bayStartSeat and bayEndSeat', () {
      expect(bayStartSeat(41), equals(41));
      expect(bayEndSeat(41), equals(48));
      expect(bayStartSeat(48), equals(41));
      expect(bayEndSeat(48), equals(48));
    });
  });
}
