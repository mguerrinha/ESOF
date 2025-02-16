import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spantry/services/authentication/firebase_auth_handler.dart';
import 'package:spantry/pages/splash_page.dart';
import 'package:spantry/utils/utils.dart';

class SignUp extends StatefulWidget {
  final Function() onClickedSignUp;

  const SignUp({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final textFieldFocusNode = FocusNode();
  bool _passwordVisible = true;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final verifyPasswordController = TextEditingController();
  bool checkBox = false;

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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 50,),

                Image.asset(
                  'lib/images/logo.png',
                  height: 100,
                ),

                const SizedBox(height: 30,),

                TextFormField(
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
                        borderRadius: BorderRadius.circular(
                            12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      labelText: 'Email'
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'Enter a valid email' : null,
                ),

                const SizedBox(height: 10,),

                TextFormField(
                  key: Key('passwordField'),
                  controller: passwordController,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    fillColor: Colors.black12,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(
                          12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                  value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null,
                ),

                const SizedBox(height: 10,),

                TextFormField(
                  key: Key('confirmPasswordField'),
                  controller: verifyPasswordController,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    fillColor: Colors.black12,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(
                          12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Confirm Password',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: _toggleObscured,
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                  obscureText: _passwordVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                  value != null && value.length < 6
                      ? 'Enter min. 6 characters'
                      : null,
                ),

                Row(
                  children: [
                    Checkbox(
                        key: Key('termsCheckbox'),
                        value: checkBox,
                        activeColor: Colors.green,
                        onChanged: (bool? value) {
                          setState(() {
                            checkBox = value!;
                          });
                        }
                    ),

                    const Text(
                      'I have read and agreed to the ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () =>
                          Navigator.of(context).push(
                              const SplashPage() as Route<Object?>),
                      child: const Text (
                        'tems and conditions',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),

                ElevatedButton(
                  key: Key('signUpButton'),
                  onPressed: () async {
                    try {
                      final isValid = formKey.currentState!.validate();
                      if (!isValid) {
                        return;
                      }
                      if (passwordController.text != verifyPasswordController.text) {
                        Utils.showSnackBar('Password doesn\'t match', Colors.red);
                        return;
                      }
                      if (!checkBox) {
                        Utils.showSnackBar('Need to accept terms and conditions', Colors.red);
                        return;
                      }
                      await FirebaseAuthHandler().signUp(emailController, passwordController);
                    } on FirebaseAuthException catch (e) {
                      Utils.showSnackBar(e.message, Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(180, 60),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),

                const SizedBox(height: 24,),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    text: 'Already have an account?   ',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignUp,
                        text: 'Log In',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30,),

                const Text(
                  'Or sign up with:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10,),

                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await FirebaseAuthHandler().signUpWithGoogle();
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
        )
    );
  }
}
