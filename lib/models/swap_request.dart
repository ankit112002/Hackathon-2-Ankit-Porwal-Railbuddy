enum SwapRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  invalid;

  static SwapRequestStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return SwapRequestStatus.accepted;
      case 'rejected':
        return SwapRequestStatus.rejected;
      case 'cancelled':
        return SwapRequestStatus.cancelled;
      case 'invalid':
        return SwapRequestStatus.invalid;
      case 'pending':
      default:
        return SwapRequestStatus.pending;
    }
  }

  String get name => toString().split('.').last;
}

class SwapRequest {
  final String id;
  final String tripId;
  final String requesterId;
  final String targetId;
  final String requesterSeat;
  final String targetSeat;
  final String? planId;
  final String? message;
  final SwapRequestStatus status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  const SwapRequest({
    required this.id,
    required this.tripId,
    required this.requesterId,
    required this.targetId,
    required this.requesterSeat,
    required this.targetSeat,
    this.planId,
    this.message,
    required this.status,
    this.createdAt,
    this.respondedAt,
  });

  factory SwapRequest.fromMap(Map<String, dynamic> m) {
    return SwapRequest(
      id: m['id'] as String,
      tripId: m['trip_id'] as String,
      requesterId: m['requester_id'] as String,
      targetId: m['target_id'] as String,
      requesterSeat: m['requester_seat'] as String,
      targetSeat: m['target_seat'] as String,
      planId: m['plan_id'] as String?,
      message: m['message'] as String?,
      status: SwapRequestStatus.fromString(m['status'] as String? ?? 'pending'),
      createdAt: m['created_at'] != null
          ? DateTime.tryParse(m['created_at'].toString())
          : null,
      respondedAt: m['responded_at'] != null
          ? DateTime.tryParse(m['responded_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'requester_id': requesterId,
      'target_id': targetId,
      'requester_seat': requesterSeat,
      'target_seat': targetSeat,
      'plan_id': planId,
      'message': message,
      'status': status.name,
      'created_at': createdAt?.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }
}
