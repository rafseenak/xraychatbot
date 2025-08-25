class Loginresponse {
  final String? userName;
  final String? hospitalName;
  final String status;
  final String? role;
  final String? message;
  final int statusCode;
  Loginresponse({
    this.hospitalName,
    required this.statusCode,
    this.role,
    this.userName,
    this.message,
    required this.status,
  });
}