import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xraychatboat/bloc/auth/auth_bloc.dart';
import 'package:xraychatboat/home.dart';
import 'package:xraychatboat/login.dart';
import 'package:xraychatboat/sign_up.dart';

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(Authentication());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state1) {
        if (state1 is LoginError || state1 is SignUpError) {
          final errorMessage = (state1 is LoginError)
              ? state1.errorMessage
              : (state1 as SignUpError).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
        if(state1 is SignUpSuccess){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration Successfull! Please, Login to continue.")),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is Authenticated) {
            return MyHomePage(title: '');
          }
          if (state is SignUpInitial || state is SignUpError || state is SignUpLoading) {
            return SignUpScreen();
          }
          if (state is UnAuthenticated || state is LoginError || state is LoginInitial || state is SignUpSuccess || state is LoginLoading) {
            return LoginScreen();
          }
          return const Scaffold();
        },
      ),
    );
  }
}
