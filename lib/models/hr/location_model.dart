class UserLocation {
  final String name;
  final double lat;
  final double lng;
  final String status;
  final bool qrEnabled;
  

  UserLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.qrEnabled,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      qrEnabled: json['qrEnabled'] == false,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name': name,
      'lat': lat,
      'lng': lng,
      'status': status,
      'qrEnabled': qrEnabled,
    };
    return m;
  }
}

