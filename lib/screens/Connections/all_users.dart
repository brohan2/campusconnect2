import 'package:campusconnect/screens/Connections/my_requests.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_requests.dart'; // Assuming you have the chat requests page
// import 'my_sent_chat_requests.dart'; // Assuming you have the page to show sent chat requests
import 'user_details.dart'; // Assuming you have the user details page

class UserListPage extends StatelessWidget {
  final String currentUserId; // Add current user ID

  UserListPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading users'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users available'));
          }

          final users = snapshot.data!.docs
              .where((user) => user.id != currentUserId) // Filter out current user
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final userName = userData['name'] ?? 'Unknown';
              final userRollNumber = userData['rollNumber'] ?? 'N/A';
              final userSkills = userData['skills'] ?? [];
              final userAchievements = userData['achievements'] ?? [];

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text('Roll Number: $userRollNumber'),
                      SizedBox(height: 5),
                      Text('Skills: ${userSkills.join(', ')}'),
                      SizedBox(height: 5),
                      Text('Achievements: ${userAchievements.join(', ')}'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsPage(userId: userId),
                            ),
                          );
                        },
                        child: Text('View Details'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chat_requests', // Add unique heroTag
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatRequestsPage()),
              );
            },
            child: Icon(Icons.message),
            backgroundColor: Colors.orange,
            tooltip: 'Chat Requests',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'my_chat_requests', // Add unique heroTag for the second button
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySentChatRequestsPage(currentUserId: currentUserId),
                ),
              );
            },
            child: Icon(Icons.send),
            backgroundColor: Colors.blue,
            tooltip: 'My Chat Requests',
          ),
        ],
      ),
    );
  }
}
