import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spantry/pages/authentication/forgot_password_page.dart';
import 'package:spantry/services/firestore/profile_management.dart';
import 'package:spantry/utils/pick_image.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  String _imageURL = "";
  bool _isButtonVisible = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfilePic();
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if (img != null) {
      setState(() {
        _image = img;
        _isButtonVisible = true;
      });
    }
  }

  Future<void> saveProfilePic(Uint8List? img) async {
    if (img != null) {
      String response = await ProfileManagement().saveProfilePicData(file: img);
      if (response == 'success') {
        fetchUserProfilePic(); // Refresh the profile picture URL
      }
    }
    setState(() {
      _isButtonVisible = false;
    });
  }

  Future<void> fetchUserProfilePic() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && mounted) {
      setState(() {
        _imageURL = userDoc['profilePicURL'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 100,
            ),
            Center(
              child: Stack(
                children: [
                  _imageURL != ""
                      ? CircleAvatar(
                          radius: 70, backgroundImage: NetworkImage(_imageURL))
                      : const CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                              'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 95,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Text(
                  FirebaseAuth.instance.currentUser!.email.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  label: const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ]),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.exit_to_app, color: Colors.green),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ),
            if (_isButtonVisible)
              ElevatedButton(
                onPressed: () async {
                  await saveProfilePic(_image);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
