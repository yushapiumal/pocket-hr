class TeamMember {
  final String id;
  final String userName;
  final String epfNumber;

  TeamMember({
    required this.id,
    required this.userName,
    required this.epfNumber,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      epfNumber: json['epfNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'epfNumber': epfNumber,
    };
  }
}