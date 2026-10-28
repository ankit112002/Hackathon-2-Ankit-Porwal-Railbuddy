enum CohesionLevel {
  sameBay,
  sameCoach,
  otherCoach,
}

enum SeatOccupancyStatus {
  yourGroup,
  openToSwap,
  occupied,
}

class Passenger {
  final String id;
  final String name;
  final bool isCurrentUser;
  final String coach;
  final int seatNumber;
  final String berthType;
  final String? bay;
  final String? pairedWith;
  final CohesionLevel cohesionLevel;
  final String? statusNote;
  final String avatarLetter;

  Passenger({
    required this.id,
    required this.name,
    this.isCurrentUser = false,
    required this.coach,
    required this.seatNumber,
    required this.berthType,
    this.bay,
    this.pairedWith,
    required this.cohesionLevel,
    this.statusNote,
    required this.avatarLetter,
  });

  String get seatTag => '$coach / $seatNumber';

  Passenger copyWith({
    String? coach,
    int? seatNumber,
    String? berthType,
    String? bay,
    String? pairedWith,
    CohesionLevel? cohesionLevel,
    String? statusNote,
  }) {
    return Passenger(
      id: id,
      name: name,
      isCurrentUser: isCurrentUser,
      coach: coach ?? this.coach,
      seatNumber: seatNumber ?? this.seatNumber,
      berthType: berthType ?? this.berthType,
      bay: bay ?? this.bay,
      pairedWith: pairedWith ?? this.pairedWith,
      cohesionLevel: cohesionLevel ?? this.cohesionLevel,
      statusNote: statusNote ?? this.statusNote,
      avatarLetter: avatarLetter,
    );
  }
}

class CoachSeat {
  final int seatNumber;
  final String berthCode; // LB, MB, UB, SL, SU
  final String berthName;
  final String? passengerLabel;
  final SeatOccupancyStatus status;
  final String? swapDetails;
  final bool isCurrentUser;
  final bool isTargetForOptimization;

  CoachSeat({
    required this.seatNumber,
    required this.berthCode,
    required this.berthName,
    this.passengerLabel,
    required this.status,
    this.swapDetails,
    this.isCurrentUser = false,
    this.isTargetForOptimization = false,
  });

  CoachSeat copyWith({
    SeatOccupancyStatus? status,
    String? passengerLabel,
    bool? isTargetForOptimization,
  }) {
    return CoachSeat(
      seatNumber: seatNumber,
      berthCode: berthCode,
      berthName: berthName,
      passengerLabel: passengerLabel ?? this.passengerLabel,
      status: status ?? this.status,
      swapDetails: swapDetails,
      isCurrentUser: isCurrentUser,
      isTargetForOptimization: isTargetForOptimization ?? this.isTargetForOptimization,
    );
  }
}

class SwapRequestItem {
  final String id;
  final String passengerName;
  final String currentSeat;
  final String targetSeat;
  final String reason;
  final String status; // 'pending', 'accepted', 'completed'
  final String timeAgo;

  SwapRequestItem({
    required this.id,
    required this.passengerName,
    required this.currentSeat,
    required this.targetSeat,
    required this.reason,
    required this.status,
    required this.timeAgo,
  });
}
