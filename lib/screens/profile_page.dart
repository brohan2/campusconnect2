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

  // Controllers for adding new skills/achievements
  final _newSkillController = TextEditingController();
  final _newAchievementController = TextEditingController();

  List<String> _skills = [];
  List<String> _achievements = [];

  bool _isEditMode = false; // Toggle for edit mode

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

        final userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data();
            _skills = List<String>.from(_userData?['skills'] ?? []);
            _achievements = List<String>.from(_userData?['achievements'] ?? []);
          });
        } else {
          _showErrorDialog('No user data found for document ID: $uid');
        }
      } else {
        _showErrorDialog('No user logged in.');
      }
    } catch (e) {
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

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _updateUserData() async {
    if (_currentUser != null) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'skills': _skills,
          'achievements': _achievements,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        _showErrorDialog('Failed to update profile: $e');
      }
    }
  }

  // Add new skill to the list
  void _addSkill() {
    if (_newSkillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_newSkillController.text.trim());
        _newSkillController.clear();
      });
    }
  }

  // Add new achievement to the list
  void _addAchievement() {
    if (_newAchievementController.text.trim().isNotEmpty) {
      setState(() {
        _achievements.add(_newAchievementController.text.trim());
        _newAchievementController.clear();
      });
    }
  }

  // Remove a skill
  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  // Remove an achievement
  void _removeAchievement(int index) {
    setState(() {
      _achievements.removeAt(index);
    });
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.orange,
          child: Text(
            _userData != null && _userData!['name'] != null
                ? _userData!['name'][0]
                : '',
            style: TextStyle(color: Colors.white, fontSize: 40),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userData!['name'] ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _userData!['email'] ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Roll Number: ${_userData!['rollNumber'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            _buildListSection(
              title: 'Skills',
              items: _skills,
              controller: _newSkillController,
              onAddItem: _addSkill,
              onRemoveItem: _removeSkill,
            ),
            SizedBox(height: 16),
            _buildListSection(
              title: 'Achievements',
              items: _achievements,
              controller: _newAchievementController,
              onAddItem: _addAchievement,
              onRemoveItem: _removeAchievement,
            ),
            SizedBox(height: 16),
            // Only show the "Update Profile" button in edit mode
            if (_isEditMode)
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('Save Profile'),
              ),
          ],
        ),
      ),
    );
  }

  // Build the list section for Skills and Achievements
  Widget _buildListSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required VoidCallback onAddItem,
    required void Function(int index) onRemoveItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (_isEditMode) ...[
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => onRemoveItem(index),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Add new $title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: onAddItem,
                child: Text('Add'),
              ),
            ],
          ),
        ] else ...[
          // If not in edit mode, display items as a simple list
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true; // Enable edit mode
                });
              },
            ),
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                setState(() {
                  _isEditMode = false; // Disable edit mode and save changes
                  _updateUserData();
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _userData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        SizedBox(height: 20),
                        _buildUserDetails(),
                      ],
                    )
                  : Center(child: Text('No data available')),
            ),
    );
  }

  @override
  void dispose() {
    _newSkillController.dispose();
    _newAchievementController.dispose();
    super.dispose();
  }
}
