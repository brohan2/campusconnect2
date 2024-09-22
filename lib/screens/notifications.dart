import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collaboration Requests'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Please log in to view collaboration requests'));
          }

          final currentUser = snapshot.data!;

          // Query all collaboration requests
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('collaboration_requests')
                .where('creatorUID', isEqualTo: currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading requests: ${snapshot.error}'));
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
    
    // Store the status locally
    String status = data['status'];

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          'Project: ${data['projectName']}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('Requester: ${data['requesterEmail']}', style: TextStyle(color: Colors.grey[700])),
            Text('Creator ID: ${data['creatorID']}', style: TextStyle(color: Colors.grey[700])),
            Text('Message: ${data['message']}', style: TextStyle(color: Colors.grey[700])),
            Text('Requested At: ${requestedAt.toLocal()}', style: TextStyle(color: Colors.grey[700])),
            Text('Status: $status', style: TextStyle(color: status == 'pending' ? Colors.orange : Colors.green)),
          ],
        ),
        trailing: status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _updateRequestStatus(context, requests[index].id, 'accepted');
                      status = 'accepted'; // Update local status
                    },
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _updateRequestStatus(context, requests[index].id, 'rejected');
                      status = 'rejected'; // Update local status
                    },
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              )
            : Text(status, style: TextStyle(color: status == 'rejected' ? Colors.red : Colors.green)),
      ),
    );
  },
);

           
      
            },
          );
        },
      ),
    );
  }

  Future<void> _updateRequestStatus(BuildContext context, String requestId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('collaboration_requests')
          .doc(requestId)
          .update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }
}
