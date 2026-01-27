class MyLeavesModel {
  String leaveTitle;
  String fromDate;
  String toDate;
  bool coveringEmployee;
  String leaveType;
  String type;
  String session;
  String description;
  String status;

  MyLeavesModel({
    required this.leaveTitle,
    required this.fromDate,
    required this.toDate,
    required this.coveringEmployee,
    required this.leaveType,
    required this.type,
    required this.session,
    required this.description,
    required this.status,
  });

  factory MyLeavesModel.fromJson(Map<String, dynamic> json) {
    return MyLeavesModel(
      leaveTitle: json['leave_title'] as String,
      fromDate: json['from_date'] as String,
      toDate: json['to_date'] as String,
      coveringEmployee: json['covering_employee'] as bool,
      leaveType: json['leave_type'] as String,
      type: json['type'] as String,
      session: json['session'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
    );
  }
}
