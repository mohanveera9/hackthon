class SupportStaffModel {
  final String id;
  final String name;
  final String phno;
  final String position;

  SupportStaffModel({
    required this.id,
    required this.name,
    required this.phno,
    required this.position,
  });

  factory SupportStaffModel.fromJson(Map<String, dynamic> json) {
    return SupportStaffModel(
      id: json['_id'],
      name: json['name'],
      phno: json['phno'],
      position: json['position'],
    );
  }
}
