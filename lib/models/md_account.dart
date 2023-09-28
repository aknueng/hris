class MAccount {
  final String code;
  final String name;
  final String surn;
  final String shortName;
  final String fullName;
  final String tName;
  final String tSurn;
  final DateTime joinDate;
  final String tFullName;
  final String posit;
  final String token;
  final String role;
  final String telephone;
  final DateTime logInDate;

  MAccount({
    required this.code,
    required this.name,
    required this.surn,
    required this.shortName,
    required this.fullName,
    required this.tName,
    required this.tSurn,
    required this.joinDate,
    required this.tFullName,
    required this.posit,
    required this.token,
    required this.role,
    required this.telephone,
    required this.logInDate,
  });

  factory MAccount.fromJson(Map<String, dynamic> json) {
    return MAccount(
      code: json['code'],
      name: json['name'],
      surn: json['surn'],
      shortName: json['shortName'],
      fullName: json['fullName'],
      tName: json['tName'],
      tSurn: json['tSurn'],
      joinDate: DateTime.parse(json['joinDate']),
      tFullName: json['tFullName'],
      posit: json['posit'],
      token: json['token'],
      role: json['role'],
      telephone: json['telephone'],
      logInDate: DateTime.parse(json['logInDate']),
    );
  }
}
