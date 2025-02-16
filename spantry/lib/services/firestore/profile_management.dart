import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ProfileManagement {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage
        .ref()
        .child(childName)
        .child(FirebaseAuth.instance.currentUser!.uid.toString());
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveProfilePicData({
    required Uint8List file,
  }) async {
    String resp = "AN ERROR OCURRED";
    try {
      String imageUrl = await uploadImageToStorage('profileImage', file);

      //await _firestore.collection('users').add({'profileImageLink': imageUrl});
      await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'profilePicURL': imageUrl,
      });

      resp = 'success';
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }

  Future<String> getProfileURL({
    required Uint8List file,
  }) async {
    String resp = "AN ERROR OCURRED";
    String imageUrl = "";

    try {
      imageUrl = await uploadImageToStorage('profileImage', file);
    } catch (err) {
      resp = err.toString();
    }
    return imageUrl;
  }
}
