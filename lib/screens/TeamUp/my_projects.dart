import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProjectsPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Projects')),
        body: Center(child: Text('Please log in to view your projects.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(200)),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('createdByUID', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading your projects'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No projects found.'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final data = project.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'Unknown';

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['projectName'] ?? 'Unnamed Project',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                        // Text(
                        //   'Status: $status',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //     color: status == 'completed'
                        //         ? Colors.green
                        //         : status == 'in progress'
                        //             ? Colors.orange
                        //             : Colors.red,
                        //   ),
                        // ),
                        // Icon(
                        //   status == 'completed'
                        //       ? Icons.check_circle
                        //       : status == 'in progress'
                        //           ? Icons.work
                        //           : Icons.warning,
                        //   color: status == 'completed'
                        //       ? Colors.green
                        //       : status == 'in progress'
                        //           ? Colors.orange
                        //           : Colors.red,
                        // ),
                      // ],
                    // ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
