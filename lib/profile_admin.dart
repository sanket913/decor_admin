import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decorar_admin/theme.dart';
import 'edit_admin.dart';
import 'login_adm.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Profile')),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.red, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 30.0),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Admin')
              .doc('decorAR@admin') // Replace with your document ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No profile data available'));
            } else {
              final profileData = snapshot.data!.data()!;
              final profileImageUrl = profileData['profilePicture'] ?? '';
              final profileText = profileData['username'] ?? '';

              return ProfileBody(
                profileImageUrl: profileImageUrl,
                profileText: profileText,
              );
            }
          },
        ),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final String profileImageUrl;
  final String profileText;

  const ProfileBody({
    required this.profileImageUrl,
    required this.profileText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20), // Add space between app bar and profile picture
        GestureDetector(
          onTap: () {
            _showZoomedImage(context, profileImageUrl);
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.network(
                profileImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 10), // Add space between profile picture and text
        Text(
          profileText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20), // Add space between text and buttons container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2), // Transparent grey
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                _buildButton(
                  icon: Icons.edit,
                  text: 'Edit Profile',
                  onTap: () {
                    // Edit profile action
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()), // Navigate to EditProfilePage
                    );
                  },
                ),
                SizedBox(height: 10), // Add space between buttons
                _buildButton(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () async {
                    // Perform logout action here
                    // For example, you can use FirebaseAuth.instance.signOut() to sign out the user
                    // Then, navigate to the LoginPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showZoomedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black.withOpacity(0.5), // Background with less opacity
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildButton({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(width: 10), // Add space between icon and text
              Text(text),
            ],
          ),
          Icon(Icons.arrow_forward_ios), // Arrow aligned to the right
        ],
      ),
    ),
  );
}

class ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context, listen: false);

    return GestureDetector(
      onTap: () {
        theme.toggleTheme();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.5), // Transparent grey color
        ),
        child: Center(
          child: Icon(
            theme.currentTheme == theme.lightTheme
                ? Icons.wb_sunny
                : Icons.nightlight_round,
            color: theme.currentTheme == theme.lightTheme
                ? Colors.black
                : Colors.green,
          ),
        ),
      ),
    );
  }
}
