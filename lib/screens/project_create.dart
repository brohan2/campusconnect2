import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _projectNameController = TextEditingController();
  final _domainController = TextEditingController();
  final _purposeController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _createProject() async {
    if (_projectNameController.text.isEmpty ||
        _domainController.text.isEmpty ||
        _purposeController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final currentUser = _auth.currentUser;

      await FirebaseFirestore.instance.collection('projects').add({
        'projectName': _projectNameController.text.trim(),
        'domain': _domainController.text.trim(),
        'purpose': _purposeController.text.trim(),
        'deadline': _deadlineController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser?.email, // Store the creator's email
        'createdByUID': currentUser?.uid, // Store the creator's UID for reference
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error creating project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create project')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(labelText: 'Project Name *'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _domainController,
              decoration: InputDecoration(labelText: 'Domain *'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(labelText: 'Purpose *'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Deadline (optional)',
                hintText: 'Enter date in YYYY-MM-DD format',
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Project Description *'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createProject,
              child: Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}
