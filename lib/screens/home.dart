import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome text
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),

            // Button to navigate to Profile Page
            ElevatedButton(
              onPressed: () {
                // Navigate to the Profile page
                Navigator.pushNamed(context, '/profile');
              },
              child: Text('Go to Profile'),
            ),
            SizedBox(height: 20),

            // Button to navigate to the Team Up (Project List) Page
            ElevatedButton(
              onPressed: () {
                // Navigate to the Project List page
                Navigator.pushNamed(context, '/projects');
              },
              child: Text('Explore Projects (Team Up)'),
            ),
          ],
        ),
      ),
    );
  }
}
