class AttendanceModel {
  String day;
  String dow;
  String type;
  bool isOffday;
  Map<String, dynamic> boilerPlate;

  AttendanceModel({
    required this.day,
    required this.dow,
    required this.type,
    required this.isOffday,
    required this.boilerPlate,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      day: json['day'] as String,
      dow: json['dow'] as String,
      type: json['type'] as String,
      isOffday: json['isOffday'] as bool,
      boilerPlate: json['boiler_plate'] as Map<String, dynamic>,
    );
  }
}
