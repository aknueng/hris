class MUserInfo {
  final String userId;
  final String username;
  final String password;
  final String empCode;
  final String empFullName;
  final String empPosit;
  final String role;
  final String status;

  MUserInfo({
    required this.userId,
    required this.username,
    required this.password,
    required this.empCode,
    required this.empFullName,
    required this.empPosit,
    required this.role,
    required this.status,
  });

  factory MUserInfo.fromJson(Map<String, dynamic> json) {
    return MUserInfo(
        userId: json['userId'].toString(),
        username: json['username'].toString(),
        password: json['password'].toString(),
        empCode: json['empCode'].toString(),
        empFullName: json['empFullName'].toString(),
        empPosit: json['empPosit'].toString(),
        role: json['role'].toString(),
        status: json['status'].toString());
  }
}
