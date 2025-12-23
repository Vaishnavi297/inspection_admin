class Appointment {
  final String id;
  final String userId;
  final String vehicleId;
  final String stationId;
  final DateTime scheduledAt;
  final String status;

  Appointment({required this.id, required this.userId, required this.vehicleId, required this.stationId, required this.scheduledAt, required this.status});

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      userId: map['userId'] as String,
      vehicleId: map['vehicleId'] as String,
      stationId: map['stationId'] as String,
      scheduledAt: DateTime.parse(map['scheduledAt'].toString()),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'stationId': stationId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
    };
  }
}

