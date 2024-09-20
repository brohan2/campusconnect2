import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Collaboration Requests'),
        ),
        body: Center(child: Text('Please log in to view collaboration requests')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Collaboration Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('collaboration_requests')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading requests'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No collaboration requests found'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestedAt = (data['requestedAt'] is Timestamp)
                  ? (data['requestedAt'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Project: ${data['projectName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requester: ${data['requesterEmail']}'),
                      Text('Requested At: ${requestedAt.toLocal()}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Handle approval or rejection logic if needed
                    },
                    child: Text('Review'),
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
