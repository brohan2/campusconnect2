import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectListPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  Future<void> _requestCollaboration(BuildContext context, DocumentSnapshot project) async {
    final currentUser = _auth.currentUser;
    final creatorUID = project['createdByUID'];

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to request collaboration')),
      );
      return;
    }

    final messageController = TextEditingController();

    final projectID = project.id;
    final existingRequestQuery = await FirebaseFirestore.instance
        .collection('collaboration_requests')
        .where('projectID', isEqualTo: projectID)
        .where('requesterUID', isEqualTo: currentUser.uid)
        .get();

    if (existingRequestQuery.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already requested collaboration for this project')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send a message to the project owner'),
        content: TextField(
          controller: messageController,
          decoration: InputDecoration(hintText: 'Enter your message'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a message')),
                );
                return;
              }

              try {
                final creatorDoc = await FirebaseFirestore.instance.collection('users').doc(creatorUID).get();
                final creatorEmail = creatorDoc['email'];
                final creatorID = creatorDoc['rollNumber'];

                await FirebaseFirestore.instance.collection('collaboration_requests').add({
                  'projectID': projectID,
                  'projectName': project['projectName'],
                  'requesterEmail': currentUser.email,
                  'requesterUID': currentUser.uid,
                  'creatorEmail': creatorEmail,
                  'creatorID': creatorID,
                  'creatorUID': creatorUID,
                  'requestedAt': FieldValue.serverTimestamp(),
                  'status': 'pending',
                  'message': message,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Collaboration request sent')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                print('Error requesting collaboration: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send request')),
                );
              }
            },
            child: Text('Send'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getProjectCreatorDetails(String creatorUID) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(creatorUID).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('TeamUp'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(200)),
        ),
        actions: [
          _buildNotificationButton(context),
          _buildMyRequestsButton(context),
          _buildMyProjectsButton(context), // Add My Projects button here
        ],
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

          final filteredProjects = projects.where((project) {
            final data = project.data() as Map<String, dynamic>;
            return data['createdByUID'] != currentUser?.uid;
          }).toList();

          if (filteredProjects.isEmpty) {
            return Center(child: Text('No projects available for collaboration.'));
          }

          return ListView.builder(
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              final data = project.data() as Map<String, dynamic>;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getProjectCreatorDetails(data['createdByUID']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final creatorData = userSnapshot.data;
                  final creatorName = creatorData?['name'] ?? 'Unknown';
                  final creatorID = creatorData?['rollNumber'] ?? 'N/A';

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['projectName'] ?? 'Unnamed Project',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Domain: ${data['domain']}'),
                        Text('Purpose: ${data['purpose']}'),
                        Text('Description: ${data['description']}'),
                        SizedBox(height: 10),
                        Divider(),
                        Text(
                          'Project Creator:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('Name: $creatorName'),
                        Text('ID: $creatorID'),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _requestCollaboration(context, project),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: Text('Collaborate'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createProject');
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        tooltip: 'Create Project',
      ),
    );
  }

  // Function to build the notification button
  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.red,
            child: Text(
              '5', // Example notification count, can be dynamic
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  // Function to build the My Requests button
  Widget _buildMyRequestsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/myRequests');
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.orange,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: Colors.orange),
        ),
        icon: Icon(Icons.list_alt, color: Colors.orange),
        label: Text(
          'My Requests',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Function to build the My Projects button
  Widget _buildMyProjectsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/myProjects');
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.orange,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: Colors.orange),
        ),
        icon: Icon(Icons.folder, color: Colors.orange),
        label: Text(
          'My Projects',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
