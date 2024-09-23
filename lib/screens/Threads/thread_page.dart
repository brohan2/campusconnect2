import 'package:campusconnect/screens/Threads/create_thread.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThreadsPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Threads'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('threads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading threads'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No threads available'));
          }

          final threads = snapshot.data!.docs;

          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final threadData = threads[index].data() as Map<String, dynamic>;
              final threadID = threads[index].id;
              final creatorUID = threadData['questionerUID'];

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
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(creatorUID)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Text('Loading creator info...');
                          }
                          if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
                            return Text('User not found');
                          }

                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                          final creatorName = userData?['name'] ?? 'Unknown';
                          final creatorRollNumber = userData?['rollNumber'] ?? 'N/A';

                          return Text(
                            '$creatorName ($creatorRollNumber)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        threadData['question'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _RepliesSection(threadID: threadID),
                      SizedBox(height: 10),
                      _ReplyInput(threadID: threadID),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateThreadPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _RepliesSection extends StatefulWidget {
  final String threadID;

  const _RepliesSection({Key? key, required this.threadID}) : super(key: key);

  @override
  __RepliesSectionState createState() => __RepliesSectionState();
}

class __RepliesSectionState extends State<_RepliesSection> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _showReplies = !_showReplies;
            });
          },
          child: Text(
            _showReplies ? 'Hide Replies' : 'Show Replies',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        if (_showReplies) _buildRepliesList(),
      ],
    );
  }

  Widget _buildRepliesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('threads')
          .doc(widget.threadID)
          .collection('replies')
          .snapshots(),
      builder: (context, replySnapshot) {
        if (replySnapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading replies...');
        }
        final replies = replySnapshot.data?.docs ?? [];

        return Column(
          children: replies.map((reply) {
            final replyData = reply.data() as Map<String, dynamic>;
            final replierUID = replyData['replierUID'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(replierUID)
                  .get(),
              builder: (context, replierSnapshot) {
                if (replierSnapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text('Loading replier info...'),
                  );
                }
                if (replierSnapshot.hasError || !replierSnapshot.hasData || replierSnapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text('User not found'),
                  );
                }
                final replierData = replierSnapshot.data!.data() as Map<String, dynamic>?;

                final replierName = replierData?['name'] ?? 'Unknown';
                final replierRollNumber = replierData?['rollNumber'] ?? 'N/A';

                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text(replyData['reply']),
                    subtitle: Text(
                      'Replied by: $replierName ($replierRollNumber)',
                      style: TextStyle(color: Colors.grey),
                    ),
                    dense: true,
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReplyInput extends StatefulWidget {
  final String threadID;

  const _ReplyInput({Key? key, required this.threadID}) : super(key: key);

  @override
  __ReplyInputState createState() => __ReplyInputState();
}

class __ReplyInputState extends State<_ReplyInput> {
  final _replyController = TextEditingController();

  Future<void> _addReply(String threadID, String replyText) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || replyText.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('threads')
          .doc(threadID)
          .collection('replies')
          .add({
        'reply': replyText,
        'replierUID': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _replyController.clear(); // Clear the input after sending
    } catch (e) {
      print('Error adding reply: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Add a reply...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange, width: 1.5),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _addReply(widget.threadID, _replyController.text),
          child: Text('Send'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
