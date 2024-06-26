import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'home_adm.dart';

class ContactReportPage extends StatefulWidget {
  @override
  _ContactReportPageState createState() => _ContactReportPageState();
}

class _ContactReportPageState extends State<ContactReportPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    final isLightTheme = theme.brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Contact Reports')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('contact').snapshots(),
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
                return Center(child: Text('No contact reports available'));
              } else {
                var reports = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var report = reports[index];
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report['subject'],
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Status: ${report['status']}',
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: getStatusColor(report['status']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    _showReportDetailsDialog(context, report);
                                  },
                                  color: isLightTheme ? Colors.black : theme.colorScheme.secondary,
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showStatusUpdateDialog(context, report);
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

  Future<void> _refreshData() async {
    setState(() {});
  }

  void _showReportDetailsDialog(BuildContext context, QueryDocumentSnapshot report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Report Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subject: ${report['subject']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Message: ${report['message']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Name: ${report['name']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Email: ${report['email']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Phone: ${report['phone']}', style: theme.textTheme.bodyLarge),
              SizedBox(height: 10),
              Text('Status: ${report['status']}', style: theme.textTheme.bodyLarge!.copyWith(
                color: getStatusColor(report['status']),
              )),
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

  void _showStatusUpdateDialog(BuildContext context, QueryDocumentSnapshot report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        String status = report['status'];

        return AlertDialog(
          title: Text('Update Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: status,
                items: ['Pending', 'Reviewed', 'Resolved'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: theme.textTheme.bodyLarge),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('contact')
                    .doc(report.id)
                    .update({'status': status});
                Navigator.of(context).pop();
                _refreshData(); // Refresh data to show updated status
              },
              child: Text('Update', style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: theme.textTheme.labelLarge),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Reviewed':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
