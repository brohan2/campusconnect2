import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectListPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  Future<void> _requestCollaboration(
      BuildContext context, DocumentSnapshot project) async {
    try {
      final currentUser = _auth.currentUser;
      final creatorUID = project['createdByUID'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(creatorUID)
          .collection('collaboration_requests')
          .add({
        'projectID': project.id,
        'projectName': project['projectName'],
        'requesterEmail': currentUser?.email,
        'requesterUID': currentUser?.uid,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collaboration request sent')),
      );
    } catch (e) {
      print('Error requesting collaboration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading projects'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No projects found'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final data = projects[index].data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(); // Default to current time if missing

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
                      Text('Created By: ${data['createdBy']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _requestCollaboration(context, projects[index]),
                    child: Text('Collaborate'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a page to create a new project
          Navigator.pushNamed(context, '/createProject');
        },
        child: Icon(Icons.add),
        tooltip: 'Create Project',
      ),
    );
  }
}
