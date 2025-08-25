import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xraychatboat/services/api_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<Authentication>(_onAuthenticate);
    on<LoginSubmitEvent>(_onLoginSubmitEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<SignupEvent>(_onSignupEvent);
    on<LoginEvent>(_onLoginEvent);
    on<SignupSubmitEvent>(_onSignUpSubmitEvent);
  }

  Future<void> _onAuthenticate(Authentication event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn')??false;
    final String? userName = prefs.getString('userName');
    final String? role = prefs.getString('role');
    if (isLoggedIn) {
      emit(Authenticated(userName: userName!, role: role!));
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(LoginInitial());
  }

  Future<void> _onLoginSubmitEvent(LoginSubmitEvent event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    final prefs = await SharedPreferences.getInstance();
    try{
      final response = await apiService.login(event.userName, event.password);
      if(response.statusCode == 200){
        prefs.setBool('isLoggedIn',true);
        prefs.setString('userName',response.userName!);
        prefs.setString('role',response.role!);
        emit(Authenticated(userName: response.userName!, role: response.role!));
      }else{
        prefs.setBool('isLoggedIn',false);
        emit(LoginError(errorMessage: response.message!));
      }
    }catch(e){
      emit(LoginError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(UnAuthenticated());
  }

  Future<void> _onSignupEvent(SignupEvent event, Emitter<AuthState> emit) async {
    try{
      final response = await apiService.fetchHospitals();
      if(response.statusCode == 200){
        emit(SignUpInitial(hospitalList: response.hospitalList??[]));
      }else{
        emit(LoginError(errorMessage: 'Something Wrong. Try Again!. ${response.status}'));
      }
    }catch(e){
      emit(LoginError(errorMessage: '$e'));
    }
  }

  Future<void> _onSignUpSubmitEvent(SignupSubmitEvent event, Emitter<AuthState> emit) async {
  List<String> hospitalList = (state is SignUpInitial)
      ? (state as SignUpInitial).hospitalList
      : [];
    emit(SignUpLoading(hospitalList: hospitalList));
    try{
      final response = await apiService.signup(fullname: event.fullname, email: event.email, username: event.username, mobile: event.mobile, specialization: event.specialization, hospitalname: event.hospitalname, password: event.password);
      if(response.statusCode == 200){
        emit(SignUpSuccess());
      }else{
        emit(SignUpError(errorMessage: response.message, hospitalList: hospitalList));
      }
    }catch(e){
      emit(SignUpError(errorMessage: e.toString(), hospitalList: hospitalList));
    }
  }
}
