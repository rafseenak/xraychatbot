class SignupResponse {
  final String status;
  final String message;
  final int statusCode;
  SignupResponse({
    required this.statusCode,
    required this.message,
    required this.status,
  });
}