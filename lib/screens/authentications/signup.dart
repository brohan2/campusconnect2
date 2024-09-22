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

  bool _obscureText = true;

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
      body: SingleChildScrollView(  // Wrap everything in SingleChildScrollView
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,  // Ensure it takes the full height
          ),
          child: IntrinsicHeight(  // Ensures the content expands to the available height
            child: Stack(
              children: [
                // Background gradient
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Color(0xFFe74b1a),
                      ],
                    ),
                  ),
                ),
                // Bottom container with white background
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3,
                  ),
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Text(""),
                ),
                // Main content
                Container(
                  margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Center(
                        child: Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Campus',
                              style: TextStyle(color: Colors.orange),
                            ),
                            TextSpan(
                              text: ' Connect',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50.0),
                      Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 30.0),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextField(
                                controller: _rollNumberController,
                                decoration: InputDecoration(
                                  hintText: 'Roll Number',
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 30.0),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.0),
                              GestureDetector(
                                onTap: _signup,
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Color(0Xffff5722),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "SIGN UP",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontFamily: 'Poppins1',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 70.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
