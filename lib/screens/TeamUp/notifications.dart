import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

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
                  final formattedDate = DateFormat('yMMMd').add_jm().format(requestedAt);
                  String status = data['status'];
                  final requesterUID = data['requesterUID'];

                  // Fetch user details from the 'users' collection
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(requesterUID).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError) {
                        return Center(child: Text('Error fetching requester details: ${userSnapshot.error}'));
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return Center(child: Text('Requester details not found'));
                      }

                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      final requesterName = userData['name'] ?? 'Unknown';
                      final requesterRollNumber = userData['rollNumber'] ?? 'Unknown';

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Project and status in a row format
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Project: ${data['projectName']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'pending'
                                          ? Colors.orange
                                          : (status == 'accepted' ? Colors.green : Colors.red),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Requester info fetched from 'users' collection
                              Text('Requester: $requesterName', style: TextStyle(color: Colors.grey[700])),
                              Text('Roll Number: $requesterRollNumber', style: TextStyle(color: Colors.grey[700])),
                              Text('Email: ${data['requesterEmail']}', style: TextStyle(color: Colors.grey[700])),

                              SizedBox(height: 8),

                              // Message and date
                              Text(
                                'Message: ${data['message']}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Requested At: $formattedDate',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              SizedBox(height: 12),

                              // Buttons in row format
                              if (status == 'pending')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
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
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
