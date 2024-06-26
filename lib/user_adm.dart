import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'theme.dart'; // Import your theme.dart file
import 'home_adm.dart'; // Import HomePage and BottomNavBar

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Add a GlobalKey for RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    final isLightTheme = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Registered Users')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData, // Method to call for refreshing
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('UserDetails').get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No users available'));
              } else {
                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          border: Border.all(color: theme.colorScheme.secondary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user['name'],
                              style: theme.textTheme.bodyLarge,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    _showUserDetailsDialog(context, user);
                                  },
                                  color: isLightTheme ? Colors.black : theme.colorScheme.secondary,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteUser(user.id);
                                  },
                                  color: isLightTheme ? Colors.black : theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      backgroundColor: theme.colorScheme.background,
    );
  }

  // Method to handle refreshing data
  Future<void> _refreshData() async {
    setState(() {}); // Refresh the UI
  }

  // Method to delete a user
  Future<void> _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('UserDetails').doc(userId).delete();
    setState(() {}); // Refresh the UI after deletion
  }

  // Method to show user details dialog
  void _showUserDetailsDialog(BuildContext context, QueryDocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Access the theme data
        return AlertDialog(
          title: Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${user['name']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Email: ${user['email']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Phone Number: ${user['phone']}', style: theme.textTheme.bodyLarge), // Assuming phone is stored
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: theme.textTheme.labelLarge),
            ),
          ],
        );
      },
    );
  }
}
