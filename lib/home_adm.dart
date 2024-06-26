import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'contact_report.dart';
import 'product_adm.dart';
import 'profile_admin.dart';
import 'upload_adm.dart';
import 'blog.dart';
import 'user_adm.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> _refreshData() async {
    // Simulate a network request or data fetching process
    await Future.delayed(Duration(seconds: 2));
    // You can add your data fetching logic here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);

    Color backgroundColor = theme.currentTheme == theme.lightTheme
        ? Colors.white // Light theme background color
        : Color(0xFF2A2A2A); // Dark theme background color

    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: Container(
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF532DE0),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 30),
                      title: Text(
                        'Hello !  Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Adding border
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfile()));
                          },
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('Admin').doc('decorAR@admin').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Show a loading indicator while fetching data
                              }
                              if (snapshot.hasError) {
                                return Icon(Icons.error); // Show error icon if error occurs
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return Icon(Icons.error); // Show error icon if document not found
                              }

                              // Assuming 'profile_image_url' is the field in Firestore where you store the image URL
                              final profileImageUrl = snapshot.data!.get('profilePicture');

                              return profileImageUrl != null
                                  ? ClipOval(
                                child: Image.network(
                                  profileImageUrl,
                                  width: 60,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ) // Display the image using Image.network
                                  : Icon(Icons.error); // Show error icon if image URL is null
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.5)), // Adding border
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: RoundedButton(
                              color: Color(0xFF063B42),
                              icon: Icons.article,
                              text: 'Manage Blogs',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage()));
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.5)), // Adding border
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                            ),
                            child: RoundedButton(
                              color: Color(0xff2F053A),
                              icon: Icons.shopping_bag,
                              text: 'Manage Products',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)), // Adding border
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: RoundedButton(
                        color: Color(0xFF1C2A9F),
                        icon: Icons.supervised_user_circle,
                        text: 'Manage Users',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
                        },
                      ),
                    ),
                    SizedBox(height: 22),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)), // Adding border
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: RoundedButton(
                        color: Color(0xFF542E9A),
                        icon: Icons.contact_mail,
                        text: 'Contact Report',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ContactReportPage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, child) {
        return Container(
          height: 55, // Increased height of the navigation bar
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // Ensure it's above the system navigation control
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1C2A9F), Color(0xFF2F2B2B)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavBarItem(
                icon: Icons.home,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
                iconSize: 30, // Increased icon size
              ),
              NavBarItem(
                icon: Icons.shopping_bag,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
                },
                iconSize: 30, // Increased icon size
              ),
              NavBarItem(
                icon: Icons.article,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage()));
                },
                iconSize: 30, // Increased icon size
              ),
              NavBarItem(
                icon: Icons.person,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
                },
                iconSize: 30, // Increased icon size
              ),
            ],
          ),
        );
      },
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  NavBarItem({required this.icon, required this.onPressed, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.white,
          iconSize: iconSize,
        ),
      ],
    );
  }
}

class RoundedButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  RoundedButton({
    required this.color,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
