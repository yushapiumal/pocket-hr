class MeSubsModel {
  String id;
  String email;
  String avatar;
  String nickName;
  String initials;
  String fName;
  String lName;
  String epfNo;
  MeSubsModel({
    required this.id,
    required this.email,
    required this.nickName,
    required this.avatar,
    required this.initials,
    required this.fName,
    required this.lName,
    required this.epfNo,
  });

  factory MeSubsModel.fromJson(Map<String, dynamic> json) {
    return MeSubsModel(
      id: json['id'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      nickName: json['nickname'] as String,
      initials: json['initials'] as String,
      fName: json['first_name'] as String,
      lName: json['last_name'] as String,
      epfNo: json['cf_epf_no'] as String,
    );
  }
}
