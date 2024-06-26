import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:decorar_admin/home_adm.dart';
import 'package:decorar_admin/profile_adm.dart';
import 'package:decorar_admin/profile_admin.dart';
import 'package:decorar_admin/service/auth.dart';
import 'package:decorar_admin/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _auth = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null && password != null) {
      _usernameController.text = username;
      _passwordController.text = password;
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A), // Change app bar color to grey
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.currentTheme.textTheme.bodyLarge?.color,
        ),
      ),
      body: Container(
        color: Color(0xFF2A2A2A), // Change body background color to grey
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/login1.png', // Replace with your image path
                    width: 200,
                    height: 200,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold, // Make the text bold
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: theme.currentTheme.colorScheme.secondary.withOpacity(0.05), // 5% visibility
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.white54), // Set hint text color to white
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Set input text color to white
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: theme.currentTheme.colorScheme.secondary.withOpacity(0.05), // 5% visibility
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white54), // Set hint text color to white
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Set input text color to white
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String password = _passwordController.text;

                      bool? success = await _auth.loginUserWithEmailAndPassword(username, password);

                      if (success == true) {
                        log("User Logged In");
                        await _saveCredentials(username, password); // Save credentials
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('User does not exist.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF532DE0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text('LOGIN'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    '---- OR ----',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = await _auth.signInWithGoogle();
                      if (user != null) {
                        bool isAdmin = await _auth.verifyGoogleSignIn(user.email!);
                        if (isAdmin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MyProfile()),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('Access denied for this account. You are not an Admin'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                    _auth.signOutGoogle(); // Sign out from Google session
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('Failed to sign in with Google.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.2), // Button background color grey with 10% visibility
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google_logo.png', // Replace with your image path
                            width: 24, // Adjust the width of the image as needed
                            height: 24, // Adjust the height of the image as needed
                          ),
                          SizedBox(width: 10), // Add some space between the image and text
                          Text('Sign in with Google'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 39),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

