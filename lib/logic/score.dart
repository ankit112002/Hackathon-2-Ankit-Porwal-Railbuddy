import '../models/passenger.dart';
import 'seat_utils.dart';

int groupScore(List<Passenger> g) {
  if (g.length < 2) return 100;
  final sameCoach = g.every((p) => p.coach == g.first.coach);
  if (sameCoach && g.every((p) => bayOf(p.seatNo) == bayOf(g.first.seatNo))) {
    return 100;
  }
  if (sameCoach) return 80;
  final nos = g.map((p) => coachNo(p.coach)).toList()..sort();
  return (nos.last - nos.first <= 1) ? 60 : 20;
}

int coachSpread(List<Passenger> g) => g.map((p) => p.coach).toSet().length;

enum MemberBayStatus {
  sameBay,
  sameCoach,
  otherCoach;
}

(String, int)? getMainBay(List<Passenger> g) {
  if (g.isEmpty) return null;
  final counts = <(String, int), int>{};
  for (final p in g) {
    final key = (p.coach, bayOf(p.seatNo));
    counts[key] = (counts[key] ?? 0) + 1;
  }
  var sorted = counts.entries.toList()
    ..sort((a, b) {
      final cmp = b.value.compareTo(a.value);
      if (cmp != 0) return cmp;
      final coachCmp = coachNo(a.key.$1).compareTo(coachNo(b.key.$1));
      if (coachCmp != 0) return coachCmp;
      return a.key.$2.compareTo(b.key.$2);
    });
  return sorted.first.key;
}

MemberBayStatus getMemberStatus(Passenger p, (String, int)? mainBay) {
  if (mainBay == null) return MemberBayStatus.sameBay;
  if (p.coach == mainBay.$1 && bayOf(p.seatNo) == mainBay.$2) {
    return MemberBayStatus.sameBay;
  }
  if (p.coach == mainBay.$1) {
    return MemberBayStatus.sameCoach;
  }
  return MemberBayStatus.otherCoach;
}
