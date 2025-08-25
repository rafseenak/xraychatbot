import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xraychatboat/bloc/auth/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
            body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Material(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(25)),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "XRAYCAD",
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "SIGN UP",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          _textField('Enter Your Name', fullNameController, false),
                          _textField('Enter Username', usernameController, false),
                          _textField('Enter Email', emailController, false),
                          _textField('Enter Password', passwordController, false),
                          _textField('Enter Confirm Password', confirmPasswordController, false),
                          _textField('Enter Contact Number', contactController, false),
                          _dropdownField(
                            hintText: 'Select Hospital Name',
                            items: (state is SignUpInitial)
                              ? (state).hospitalList
                              : (state is SignUpError)
                                  ? (state).hospitalList
                                  : (state is SignUpLoading)
                                      ? (state).hospitalList
                                      : [],
                            selectedItem: hospitalNameController.text,
                            onChanged: (value) {
                              setState(() {
                                hospitalNameController.text = value!;
                              });
                            },
                            validator: (value) => value == null || value.isEmpty ? 'Please select a Specialization' : null,
                          ),
                          _textField('Enter Specialization', specializationController, false),
                          SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()){ 
                                if(passwordController.text == confirmPasswordController.text){
                                  context
                                  .read<AuthBloc>()
                                  .add(SignupSubmitEvent(
                                    fullname: fullNameController.text,
                                    email: emailController.text,
                                    username: usernameController.text,
                                    mobile: contactController.text,
                                    specialization: specializationController.text,
                                    hospitalname: hospitalNameController.text,
                                    password: passwordController.text
                                  ));
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Password and Confirm password should be same')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 67, 196, 235),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: (state is SignUpLoading) ?
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ):Text(
                              "Register",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                            child: Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(LoginEvent());
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Color.fromARGB(255, 67, 196, 235),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                child: Text("Already have an account? Login"),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
      },
    );
  }

  Widget _textField(String? hintText, TextEditingController controller, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12, color: const Color.fromARGB(255, 107, 107, 107)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 67, 196, 235), width: 2),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hintText,
    required List<String> items,
    required String selectedItem,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: DropdownButtonFormField<String>(
          value: items.contains(selectedItem) ? selectedItem : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color.fromARGB(255, 107, 107, 107),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 67, 196, 235),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          items: items.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
