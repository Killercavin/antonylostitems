import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lostitems/widgets/constantsdata.dart';

import 'user_credentials.dart';
import 'Login_screen.dart';

import 'package:intl_phone_field/intl_phone_field.dart';




class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _mobileController=TextEditingController();


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController=TextEditingController();
  final _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Background color of the AppBar
        title: Text(
          "Sign in",
          style: TextStyle(
            fontSize: 24, // Title font size
            fontWeight: FontWeight.bold, // Title font weight
            color: Colors.white, // Title text color
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {

          },
          color: Colors.white, // Leading icon color
        ),
        actions: [
          Row(
            children: [
              Text(
                "Logout",
                style: TextStyle(
                    fontSize: 21, // Logout text font size
                    color: Colors.white,
                    fontWeight: FontWeight.bold// Logout text color
                ),
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {

                },
                color: Colors.white, // Exit icon color
              ),
            ],
          ),
        ],
      )
      ,

      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                autofocus: true,
                keyboardType: TextInputType.text,
                validator: (value){
                  if(value!.isEmpty){
                    return "Please enter valid name";
                  }
                  return null;
                },
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_2_sharp,color: Colors.green,),
                  labelText: "Name",
                ),


              ),
              SizedBox(height: 20,),

              IntlPhoneField(
                autofocus: true,
                keyboardType: TextInputType.phone,


                controller: _mobileController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.call,color: Colors.green,),
                  labelText: "Phone",
                ),


              ),
              SizedBox(height: 10,),

              TextFormField(
                autofocus: false,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your email";
                  } else if (!RegExp(
                      r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}")
                      .hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Password is required";
                  } else if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 10,),
              // TextFormField(
              //   controller: _confirmPasswordController,
              //   obscureText: true,
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return "confirm password is required";
              //     } else if (_passwordController != _confirmPasswordController) {
              //       return "passwords should match";
              //     }
              //     return null;
              //   },
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.lock, color: Colors.black),
              //     labelText: 'Confirmpassword',
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                width: 500,
                height: 50,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.kPrimaryColor,

                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Register(
                        _nameController.text,
                        _mobileController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: Text('UpdateProfile'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void Register(String username, String phone, String email, String password) async {
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
    user_model.name = _nameController.text;
    user_model.mobile=_mobileController.text;
    await firebaseFirestore.collection("uid").doc(user.uid).set(user_model.toJson());

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