part of 'auth_bloc.dart';

class AuthEvent {}

class Authentication extends AuthEvent {}

class LoginEvent extends AuthEvent {}

class LoginSubmitEvent extends AuthEvent {
  final String userName;
  final String password;
  LoginSubmitEvent({
    required this.password,
    required this.userName
  });
}

class LogoutEvent extends AuthEvent {}

class SignupEvent extends AuthEvent {}

class SignupSubmitEvent extends AuthEvent {
  final String fullname;
  final String email;
  final String username;
  final String mobile;
  final String specialization;
  final String hospitalname;
  final String password;
  SignupSubmitEvent({
    required this.fullname,
    required this.email,
    required this.username,
    required this.mobile,
    required this.specialization,
    required this.hospitalname,
    required this.password,
  });
}