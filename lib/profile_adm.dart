import 'package:decorar_admin/login_adm.dart';
import 'package:decorar_admin/service/auth.dart';
import 'package:decorar_admin/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 // Import your FirestoreService class

class ProfilePage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;

                String password = _passwordController.text;

                // Add admin data to Firestore
                FirestoreService().createUserWithEmailAndPassword(username, password);
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 24.0),
            Text(
              'Toggle Theme:',
              style: TextStyle(fontSize: 20.0),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ThemeModel>(context, listen: false).toggleTheme();
              },
              child: Text('Toggle Theme'),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirestoreService().signout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text('Sign Out'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
