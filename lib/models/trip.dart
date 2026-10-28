class Trip {
  final String id;
  final String trainNo;
  final String trainName;
  final String fromStation;
  final String toStation;
  final String? departTime;
  final String? arriveTime;
  final String journeyDate;

  const Trip({
    required this.id,
    required this.trainNo,
    required this.trainName,
    required this.fromStation,
    required this.toStation,
    this.departTime,
    this.arriveTime,
    required this.journeyDate,
  });

  factory Trip.fromMap(Map<String, dynamic> m) {
    return Trip(
      id: m['id'] as String,
      trainNo: m['train_no'] as String,
      trainName: m['train_name'] as String,
      fromStation: m['from_station'] as String,
      toStation: m['to_station'] as String,
      departTime: m['depart_time'] as String?,
      arriveTime: m['arrive_time'] as String?,
      journeyDate: (m['journey_date'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'train_no': trainNo,
      'train_name': trainName,
      'from_station': fromStation,
      'to_station': toStation,
      'depart_time': departTime,
      'arrive_time': arriveTime,
      'journey_date': journeyDate,
    };
  }
}
