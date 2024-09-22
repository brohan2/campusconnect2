// File: lib/pages/ReviewRequestPage.dart

// import 'package:campusconnect/screens/chat_page.dart';
import 'package:campusconnect/screens/chatting.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the passed arguments (request data)
    final Map<String, dynamic> requestData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String projectName = requestData['projectName'];
    final String requesterEmail = requestData['requesterEmail'];
    final DateTime requestedAt = requestData['requestedAt'];
    final String projectID = requestData['projectID'];
    final String requesterUID = requestData['requesterUID'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: $projectName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Requester Email: $requesterEmail', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Requested At: $requestedAt', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Implement acceptance logic here
                    await _updateRequestStatus(projectID, requesterEmail, 'accepted');

                    // Navigate to chat page
                    // Navigator.push(
                      // context,
                      // MaterialPageRoute(
                        // builder: (context) => ChatPage(
                        //   projectName: projectName,
                        //   requesterEmail: requesterEmail,
                        // ),
                      // ),
                    // );
                  },
                  child: Text('Accept'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Implement rejection logic here
                    await _updateRequestStatus(projectID, requesterEmail, 'rejected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request Rejected')),
                    );
                  },
                  child: Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(String projectID, String requesterEmail, String status) async {
    // Update the collaboration request status in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(requesterEmail)
          .collection('collaboration_requests')
          .doc(projectID)
          .update({
        'status': status,
      });
    } catch (e) {
      print('Error updating request status: $e');
    }
  }
}
