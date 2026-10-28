import '../models/passenger.dart';
import 'seat_utils.dart';

class Match {
  final Passenger passenger;
  final int score;
  const Match(this.passenger, this.score);
}

List<Match> findMatches({
  required Passenger me,
  required List<Passenger> all,
  required List<Passenger> group,
  String? preferredBerth,
  bool sameCoachOnly = false,
  bool nearGroup = false,
  bool onlyOpen = true,
}) {
  final groupIds = group.map((g) => g.id).toSet();
  final result = <Match>[];
  for (final p in all) {
    if (p.id == me.id || groupIds.contains(p.id)) continue;
    if (onlyOpen && !p.willingToSwap) continue;
    if (sameCoachOnly && p.coach != me.coach) continue;
    var s = 0;
    if (preferredBerth != null && berthOf(p.seatNo) == preferredBerth) s += 40;
    if (p.coach == me.coach) {
      s += 30;
      final diff = (p.seatNo - me.seatNo).abs();
      s += 10 - (diff > 10 ? 10 : diff);
    }
    if (nearGroup &&
        group.any((g) => g.coach == p.coach && bayOf(g.seatNo) == bayOf(p.seatNo))) {
      s += 20;
    }
    result.add(Match(p, s));
  }
  result.sort((a, b) => b.score.compareTo(a.score));
  return result;
}
