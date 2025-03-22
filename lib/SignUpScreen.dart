import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lostitems/user_credentials.dart';
import 'login_screen.dart';

import 'package:intl_phone_field/intl_phone_field.dart';



import 'widgets/constantsdata.dart';
import '../widgets/navbar_roots.dart';
import 'bezier_card.dart';
import 'custom_buttons.dart';
import 'custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  static final TextEditingController mail = TextEditingController();
  static final TextEditingController name = TextEditingController();
  static final TextEditingController pwd = TextEditingController();
  static final TextEditingController cfmpwd = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  // bool? _hasBioSensor;
  //
  // LocalAuthentication authentication = LocalAuthentication();
  //
  // Future<void> _checkBio() async {
  //   try {
  //     _hasBioSensor = await authentication.canCheckBiometrics;
  //     if (_hasBioSensor!) {
  //       _getAuth();
  //     }
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  // }
  //
  // Future<void> _getAuth() async {
  //   bool isAuth = false;
  //   try {
  //     isAuth = await authentication.authenticate(
  //         localizedReason: 'Scan your fingerprint',
  //         options: const AuthenticationOptions(
  //             biometricOnly: true, stickyAuth: true));
  //     if (isAuth) {
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => NavBarRoots()));
  //     }
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .2),
                    const Text(
                      "Lost items",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      isPassword: false,
                      controller: mail,

                      hintText: 'Email Address',
                      validator: (value) {
                        if (!value!.isEmail) {
                          return 'Please enter valid email address';
                        } else if (value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Full Name",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.name,
                      isPassword: false,
                      controller: name,
                      hintText: 'Full Name',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.multiline,
                      isPassword: true,
                      controller: pwd,
                      hintText: 'Password',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Your Password length must be greater than 6';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Confrrm Password",
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.multiline,
                      isPassword: true,
                      controller: cfmpwd,
                      hintText: 'Conform Password',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter confirm password';
                        } else if (value.length < 6) {
                          return 'Your Password length must be greater than 6';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 55, // Match other text fields' height
                        child: IntlPhoneField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.call,
                              color: Colors.green,
                            ),
                            labelText: "Phone",
                            filled: true,
                            fillColor: const Color(0xfff3f3f4), // Match other fields
                          ),
                          onChanged: (phone) {
                            print(phone.completeNumber);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    PrimaryButton(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                         Register(
                             name.text,

                             mail.text,
                             pwd.text,
                           _mobileController.text,
                             );
                        }
                      },
                      text: "Register",
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * .10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        TextButton(
                            onPressed: () {

                            },
                            child: GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context)=>LoginScreen()));

                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    color: MyColors.kPrimaryColor, fontSize: 14),
                              ),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void Register(String username, String email, String password, String phone) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        postDetailsToFirestore(userCredential);
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }
  void postDetailsToFirestore(UserCredential userCredential) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = userCredential.user;
    UserModel user_model = UserModel();
    user_model.email = user!.email;
    user_model.password = user.uid;
    user_model.name = name.text;
    user_model.mobile=_mobileController.text;
    await firebaseFirestore.collection("details").doc(user.uid).set(user_model.toJson());

    Fluttertoast.showToast(
      msg: "Account created  successfully.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

}
