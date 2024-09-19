import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the UID of the newly created user
      final uid = userCredential.user?.uid;

      // Create a document in Firestore with auto-generated ID
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'name': _nameController.text.trim(),
          'rollNumber': _rollNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(), // Timestamp for record creation
        });

        // Navigate to the home page or show a success message
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Failed to get user ID.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      _showErrorDialog(e.message ?? 'An error occurred');
    } catch (e) {
      // Handle any other errors
      _showErrorDialog('An unexpected error occurred');
    }
  }

  // Function to show error dialogs
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
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _rollNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _rollNumberController,
              decoration: InputDecoration(labelText: 'Roll Number'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
