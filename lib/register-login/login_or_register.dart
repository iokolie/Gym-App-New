import 'package:flutter/material.dart';
import 'package:gym_app_finished/register-login/login.dart';
import 'package:gym_app_finished/register-login/register.dart';


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
    //innitially show login page

  bool showLoginPage = true;

  void togglePage(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    
          //user is logged in
          if (showLoginPage) {
            return LoginPage(
              onTap: togglePage,
            );
          }
          //user is not logged in
          else{
            return RegisterPage(
              onTap: togglePage,
              );
          }
  }
}