class Visitor {
  final String id;
  final String name;
  final String phone;
  final String purpose;
  final DateTime entryTime;
  DateTime? exitTime;
  final String status; // 'inside', 'left'
  final String? photoUrl;
  final String createdBy; // UID of the employee who created the entry

  Visitor({
    required this.id,
    required this.name,
    required this.phone,
    required this.purpose,
    required this.entryTime,
    this.exitTime,
    required this.status,
    this.photoUrl,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'purpose': purpose,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'status': status,
      'photoUrl': photoUrl,
      'createdBy': createdBy,
    };
  }

  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      purpose: map['purpose'],
      entryTime: DateTime.parse(map['entryTime']),
      exitTime: map['exitTime'] != null
          ? DateTime.parse(map['exitTime'])
          : null,
      status: map['status'],
      photoUrl: map['photoUrl'],
      createdBy: map['createdBy'],
    );
  }
}
