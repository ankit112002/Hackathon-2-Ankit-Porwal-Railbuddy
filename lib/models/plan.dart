import 'passenger.dart';

class SwapPair {
  final Passenger member; // group member who moves
  final Passenger volunteer; // other passenger who gives the seat

  const SwapPair(this.member, this.volunteer);
}

class Plan {
  final String coach;
  final int? bay; // null for a coach plan
  final List<SwapPair> swaps;
  final int targetScore; // 100 for a bay plan, 80 for a coach plan

  const Plan(this.coach, this.bay, this.swaps, this.targetScore);
}
