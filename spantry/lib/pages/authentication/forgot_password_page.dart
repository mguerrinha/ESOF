import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spantry/utils/utils.dart';
import 'package:spantry/services/authentication/firebase_auth_handler.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});


  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Material(
      child: SingleChildScrollView(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80,),

              Image.asset(
                'lib/images/logo.png',
                height: 100,
              ),

              const SizedBox(height: 30,),

              const Text(
                'Reset your\npassword',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30,),

              const Text(
                'Enter your email address and we will send you a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Email',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Enter a valid email' : null,
              ),

              const SizedBox(height: 30,),

              ElevatedButton(
                key: Key('continueButton'),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(child: CircularProgressIndicator(),);
                      });
                  try {
                    await FirebaseAuthHandler().resetPassword(emailController);
                    Utils.showSnackBar('Password Reset Email Sent', Colors.green);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } on FirebaseException catch (e) {
                    Utils.showSnackBar(e.message, Colors.red);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    ),
  );
}