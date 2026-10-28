class Group {
  final String id;
  final String tripId;
  final String name;
  final String joinCode;

  const Group({
    required this.id,
    required this.tripId,
    required this.name,
    required this.joinCode,
  });

  factory Group.fromMap(Map<String, dynamic> m) {
    return Group(
      id: m['id'] as String,
      tripId: m['trip_id'] as String,
      name: m['name'] as String,
      joinCode: m['join_code'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'join_code': joinCode,
    };
  }
}
