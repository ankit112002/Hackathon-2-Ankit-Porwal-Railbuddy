class Passenger {
  final String id;
  final String tripId;
  final String? groupId;
  final String name;
  final String coach;
  final int seatNo;
  final bool willingToSwap;

  const Passenger({
    required this.id,
    required this.tripId,
    required this.name,
    required this.coach,
    required this.seatNo,
    required this.willingToSwap,
    this.groupId,
  });

  factory Passenger.fromMap(Map<String, dynamic> m) => Passenger(
        id: m['id'] as String,
        tripId: m['trip_id'] as String,
        groupId: m['group_id'] as String?,
        name: m['name'] as String,
        coach: m['coach'] as String,
        seatNo: (m['seat_no'] as num).toInt(),
        willingToSwap: (m['willing_to_swap'] as bool?) ?? true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'trip_id': tripId,
        'group_id': groupId,
        'name': name,
        'coach': coach,
        'seat_no': seatNo,
        'willing_to_swap': willingToSwap,
      };

  Passenger copyWith({
    String? id,
    String? tripId,
    String? groupId,
    String? name,
    String? coach,
    int? seatNo,
    bool? willingToSwap,
  }) {
    return Passenger(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      coach: coach ?? this.coach,
      seatNo: seatNo ?? this.seatNo,
      willingToSwap: willingToSwap ?? this.willingToSwap,
    );
  }

  String get seatKey => '$coach/$seatNo';
  String get seatLabel => '$coach / $seatNo';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Passenger && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
