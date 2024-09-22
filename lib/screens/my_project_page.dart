// File: lib/pages/MyProjectsPage.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProjectsPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('createdByUID', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading your projects'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('You have not uploaded any projects'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final data = projects[index].data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp).toDate();

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['projectName'] ?? 'Unnamed Project'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Domain: ${data['domain']}'),
                      Text('Purpose: ${data['purpose']}'),
                      Text(
                          'Deadline: ${data['deadline']?.isEmpty ?? true ? 'Not set' : data['deadline']}'),
                      Text('Description: ${data['description']}'),
                      Text('Created At: ${createdAt.toLocal()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
