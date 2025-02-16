import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spantry/model/user_auth.dart';

class FirebaseAuthHandler {
  Future signUp(TextEditingController emailController,
      TextEditingController passwordController) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    );

    final docUser = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    UserAuth user = UserAuth(uid: docUser.id, email: emailController.text);
    final json = user.json();
    await docUser.set(json);
  }

  Future signUpWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser
        ?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    final docUser = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    UserAuth user = UserAuth(uid: docUser.id, email: FirebaseAuth.instance.currentUser?.email ?? "");
    final json = user.json();
    await docUser.set(json);
  }

  Future<UserCredential?> signInWithGoogle() async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> login(TextEditingController emailController, TextEditingController passwordController) async {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
  }

  Future resetPassword(TextEditingController emailController) async {
    return await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
  }
}