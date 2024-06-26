import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_admin.dart';
import 'theme.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('Admin').doc('decorAR@admin').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text('No data found', style: TextStyle(color: Colors.white)));
              }
              var userData = snapshot.data!.data();
              if (userData != null) {
                _fullNameController.text = userData['fullName'] ?? '';
                _emailController.text = userData['email'] ?? '';
                _passwordController.text = userData['password'] ?? '';
                _profileImageUrl = userData['profilePicture'];
              }
              return Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _profileImageUrl != null
                              ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                              : Image.asset('assets/profile-image.png', fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xFF532DE0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _navigateToCamera(context);
                            },
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'E-Mail',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.mail_outline, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.fingerprint_outlined, color: Colors.white),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF532DE0),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Save Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToCamera(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      String imageUrl = await _uploadImageToStorage(image);
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  Future<String> _uploadImageToStorage(XFile imageFile) async {
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref('profile_images').putFile(File(imageFile.path));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('Admin').doc('decorAR@admin').update({
        'profilePicture': downloadUrl,
      });
      return downloadUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  void _updateUserProfile() async {
    try {
      await FirebaseFirestore.instance.collection('Admin').doc('decorAR@admin').update({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      _showSavedSuccessfullySnackbar(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyProfile()),
      );
    } catch (error) {
      print('Error updating user profile: $error');
      // Show error message if needed
    }
  }

  void _showSavedSuccessfullySnackbar(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Profile Saved Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
