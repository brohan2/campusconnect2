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
  // final _deadlineController = TextEditingController();
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
        // 'deadline': _deadlineController.text.trim(),
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
        backgroundColor: Colors.orange,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(200)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Project Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            _buildInputField(
              controller: _projectNameController,
              label: 'Project Name *',
            ),
            SizedBox(height: 10),
            _buildInputField(
              controller: _domainController,
              label: 'Domain *',
            ),
            SizedBox(height: 10),
            _buildInputField(
              controller: _purposeController,
              label: 'Purpose *',
            ),
            // SizedBox(height: 10),
            // _buildInputField(
            //   // controller: _deadlineController,
            //   label: 'Deadline (optional)',
            //   hintText: 'Enter date in YYYY-MM-DD format',
            //   keyboardType: TextInputType.datetime,
            // ),
            SizedBox(height: 10),
            _buildInputField(
              controller: _descriptionController,
              label: 'Project Description *',
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _createProject,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text('Create Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
