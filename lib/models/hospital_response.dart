class HospitalResponse {
  final List<String>? hospitalList;
  final String status;
  final String? message;
  final int statusCode;
  HospitalResponse({
    this.hospitalList,
    required this.statusCode,
    this.message,
    required this.status,
  });
}