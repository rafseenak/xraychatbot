part of 'auth_bloc.dart';

class AuthState {}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  final String userName;
  final String role;
  Authenticated({
    required this.userName,
    required this.role,
  });
}

final class UnAuthenticated extends AuthState {}

final class LoginInitial extends AuthState {}

final class LoginError extends AuthState {
  final String errorMessage;
  LoginError({
    required this.errorMessage,
  });
}
final class LoginLoading extends AuthState {}

final class SignUpLoading extends AuthState {
  final List<String> hospitalList;
  SignUpLoading({
    required this.hospitalList,
  });
}

final class SignUpInitial extends AuthState {
  final List<String> hospitalList;
  SignUpInitial({
    required this.hospitalList,
  });
}

final class SignUpSuccess extends AuthState {}

final class SignUpError extends AuthState {
  final String errorMessage;
  final List<String> hospitalList;
  SignUpError({
    required this.hospitalList,
    required this.errorMessage,
  });
}