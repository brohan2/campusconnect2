import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        String uid = _currentUser!.uid;
        print('Current UID: $uid');

        final userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data();
          });
          print('User data found: ${_userData}');
        } else {
          print('No user data found for document ID: $uid');
          _showErrorDialog('No user data found for document ID: $uid');
        }
      } else {
        print('No user logged in.');
        _showErrorDialog('No user logged in.');
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showErrorDialog('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _userData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${_userData!['name'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Roll Number: ${_userData!['rollNumber'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Email: ${_userData!['email'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Created At: ${_userData!['createdAt']?.toDate().toLocal().toString() ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                      ],
                    )
                  : Center(child: Text('No data available')),
            ),
    );
  }
}
