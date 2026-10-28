import '../models/passenger.dart';
import '../models/plan.dart';
import 'seat_utils.dart';

Plan? bestPlan({required List<Passenger> group, required List<Passenger> all}) {
  if (group.length < 2) return null;
  final groupIds = group.map((g) => g.id).toSet();
  final others =
      all.where((p) => !groupIds.contains(p.id) && p.willingToSwap).toList();

  Plan? best;
  if (group.length <= 8) {
    final bays = <(String, int)>{
      for (final m in group) (m.coach, bayOf(m.seatNo))
    };
    for (final (coach, bay) in bays) {
      final inside = group
          .where((m) => m.coach == coach && bayOf(m.seatNo) == bay)
          .toList();
      final outside = group.where((m) => !inside.contains(m)).toList();
      final pool = others
          .where((p) => p.coach == coach && bayOf(p.seatNo) == bay)
          .toList();
      if (pool.length < outside.length) continue;

      final swaps = <SwapPair>[];
      for (final m in outside) {
        pool.sort((a, b) {
          int rank(Passenger p) =>
              berthOf(p.seatNo) == berthOf(m.seatNo) ? 0 : 1;
          return rank(a).compareTo(rank(b));
        });
        swaps.add(SwapPair(m, pool.removeAt(0)));
      }
      final candidate = Plan(coach, bay, swaps, 100);
      if (best == null ||
          swaps.length < best.swaps.length ||
          (swaps.length == best.swaps.length &&
              inside.length >
                  group
                      .where((m) =>
                          m.coach == best!.coach && bayOf(m.seatNo) == best.bay)
                      .length)) {
        best = candidate;
      }
    }
  }
  if (best != null) return best;

  // Coach plan fallback
  final counts = <String, int>{};
  for (final m in group) {
    counts[m.coach] = (counts[m.coach] ?? 0) + 1;
  }
  final coach = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final outside = group.where((m) => m.coach != coach).toList();
  final pool = others.where((p) => p.coach == coach).toList();
  if (pool.length < outside.length) return null;
  final swaps = [
    for (var i = 0; i < outside.length; i++) SwapPair(outside[i], pool[i])
  ];
  return Plan(coach, null, swaps, 80);
}
