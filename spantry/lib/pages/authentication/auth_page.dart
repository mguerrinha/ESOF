import 'package:flutter/material.dart';
import 'package:spantry/pages/authentication/login_page.dart';
import 'package:spantry/pages/authentication/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return isLogin ? Login(onClickedSignUp : toggle) : SignUp(onClickedSignUp : toggle);
  }

  void toggle() => setState(() => isLogin = !isLogin);
}
