class Soscontactsmodel {
  final String id;
  final String name;
  final String phno;
  final String position;

  Soscontactsmodel ({
    required this.id,
    required this.name,
    required this.phno,
    required this.position,
  });

  factory Soscontactsmodel .fromJson(Map<String, dynamic> json) {
    return Soscontactsmodel (
      id: json['_id'],
      name: json['name'],
      phno: json['phno'],
      position: json['position'],
    );
  }
}
