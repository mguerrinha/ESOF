import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spantry/services/authentication/firebase_auth_handler.dart';
import 'package:spantry/pages/authentication/forgot_password_page.dart';
import 'package:spantry/utils/utils.dart';

class Login extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const Login({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final textFieldFocusNode = FocusNode();
  bool _passwordVisible = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _toggleObscured() {
    setState(() {
      _passwordVisible = !_passwordVisible;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80,),

            Image.asset(
              'lib/images/logo.png',
              height: 100,
            ),

            const SizedBox(height: 40,),

            TextField(
              key: Key('emailField'),
              controller: emailController,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.black12,
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 10,),

            TextFormField(
              key: Key('passwordField'),
              controller: passwordController,
              obscureText: _passwordVisible,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.black12,
                isDense: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: GestureDetector(
                    onTap: _toggleObscured,
                    child: Icon(
                      _passwordVisible ? Icons.visibility_off_rounded : Icons
                          .visibility_rounded,
                    ),
                  ),
                ),
              ),

              // Integration Test
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
              value != null && value.length < 6
                  ? 'Enter min. 6 characters'
                  : null,
            ),

            const SizedBox(height: 40,),

            GestureDetector(
                key: Key('forgotPasswordButton'),
                child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
                );
              }
            ),

            const SizedBox(height: 30,),

            ElevatedButton(
              key: Key('loginButton'),
              onPressed: () async {
                try {
                  await FirebaseAuthHandler().login(
                      emailController, passwordController);
                } on FirebaseAuthException catch(e) {
                  Utils.showSnackBar(e.message, Colors.red);
                }
                },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(160, 60),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),

            const SizedBox(height: 20,),

            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                text: 'No account?   ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignUp,
                    text: 'Sign up',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40,),

            const Text(
              'Or login with:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20,),

            ElevatedButton.icon(
                key: Key('googleLoginButton'),
                onPressed: () async {
                  try {
                    await FirebaseAuthHandler().signInWithGoogle();
                  } on FirebaseAuthException catch (e) {
                    Utils.showSnackBar(e.message, Colors.red);
                  }
                },
                icon: Image.asset(
                  'lib/images/Google_Icons-09-512.webp',
                  height: 30,
                ),
                label: const Text(
                  'Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 40),
                  backgroundColor: Colors.green,
                )
            ),
          ],
        ),
      ),
    );
  }
}